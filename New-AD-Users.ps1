# ============================================================================
# PowerShell Active Directory User Onboarding Script
# Author: Cameron O'Brien
# Description: Automates the creation of new AD users from a CSV file
# ============================================================================

#Requires -Version 5.1
#Requires -Modules ActiveDirectory

# Start transcript for logging
$LogPath = ".\AD_UserCreation_Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
Start-Transcript -Path $LogPath

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AD User Onboarding Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# CONFIGURATION - Update these variables to match your environment
# ============================================================================

$CSVPath = ".\NewUsers.csv"
$DefaultPassword = "TempP@ssw0rd123!" # This will be changed to random passwords per user
$DomainName = "company.local" # Update with your domain
$BaseOU = "OU=Users,DC=company,DC=local" # Update with your base OU

# Department to OU mapping
$DepartmentOUs = @{
    "IT" = "OU=IT,OU=Users,DC=company,DC=local"
    "HR" = "OU=HR,OU=Users,DC=company,DC=local"
    "Sales" = "OU=Sales,OU=Users,DC=company,DC=local"
    "Finance" = "OU=Finance,OU=Users,DC=company,DC=local"
    "Marketing" = "OU=Marketing,OU=Users,DC=company,DC=local"
}

# Department to Security Group mapping
$DepartmentGroups = @{
    "IT" = "IT-Users"
    "HR" = "HR-Users"
    "Sales" = "Sales-Users"
    "Finance" = "Finance-Users"
    "Marketing" = "Marketing-Users"
}

# ============================================================================
# FUNCTIONS
# ============================================================================

function Generate-RandomPassword {
    param (
        [int]$Length = 12
    )
    
    $CharSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $Password = -join ((1..$Length) | ForEach-Object { $CharSet[(Get-Random -Maximum $CharSet.Length)] })
    
    # Ensure password meets complexity requirements
    if ($Password -notmatch "[a-z]" -or $Password -notmatch "[A-Z]" -or 
        $Password -notmatch "[0-9]" -or $Password -notmatch "[!@#$%^&*]") {
        return Generate-RandomPassword -Length $Length
    }
    
    return $Password
}

function Create-Username {
    param (
        [string]$FirstName,
        [string]$LastName
    )
    
    # Create username format: first initial + last name (e.g., jdoe)
    $Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
    
    # Check if username already exists
    $Counter = 1
    $OriginalUsername = $Username
    
    while (Get-ADUser -Filter "SamAccountName -eq '$Username'" -ErrorAction SilentlyContinue) {
        $Username = "$OriginalUsername$Counter"
        $Counter++
    }
    
    return $Username
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Check if CSV file exists
if (-not (Test-Path $CSVPath)) {
    Write-Host "[ERROR] CSV file not found: $CSVPath" -ForegroundColor Red
    Write-Host "Please create a CSV file with the following columns:" -ForegroundColor Yellow
    Write-Host "FirstName,LastName,Department,JobTitle,Email" -ForegroundColor Yellow
    Stop-Transcript
    exit
}

# Import CSV file
Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Importing CSV file..." -ForegroundColor Yellow
try {
    $Users = Import-Csv -Path $CSVPath
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Found $($Users.Count) user(s) to process" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to import CSV file: $_" -ForegroundColor Red
    Stop-Transcript
    exit
}

# Counters for summary
$SuccessCount = 0
$FailCount = 0

# Process each user
foreach ($User in $Users) {
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Processing: $($User.FirstName) $($User.LastName)" -ForegroundColor Cyan
    
    try {
        # Generate username
        $Username = Create-Username -FirstName $User.FirstName -LastName $User.LastName
        Write-Host "  Username: $Username" -ForegroundColor Gray
        
        # Generate random password
        $TempPassword = Generate-RandomPassword
        $SecurePassword = ConvertTo-SecureString $TempPassword -AsPlainText -Force
        
        # Determine OU based on department
        $TargetOU = $DepartmentOUs[$User.Department]
        if (-not $TargetOU) {
            $TargetOU = $BaseOU
            Write-Host "  [WARNING] Department '$($User.Department)' not mapped, using base OU" -ForegroundColor Yellow
        }
        
        # Create display name
        $DisplayName = "$($User.FirstName) $($User.LastName)"
        
        # User Principal Name
        $UPN = "$Username@$DomainName"
        
        # Create the AD user
        $UserParams = @{
            Name = $DisplayName
            GivenName = $User.FirstName
            Surname = $User.LastName
            SamAccountName = $Username
            UserPrincipalName = $UPN
            EmailAddress = $User.Email
            Title = $User.JobTitle
            Department = $User.Department
            Path = $TargetOU
            AccountPassword = $SecurePassword
            Enabled = $true
            ChangePasswordAtLogon = $true
        }
        
        New-ADUser @UserParams
        Write-Host "  [SUCCESS] User created: $DisplayName ($Username)" -ForegroundColor Green
        Write-Host "  Temporary Password: $TempPassword" -ForegroundColor Magenta
        
        # Add user to department security group
        $GroupName = $DepartmentGroups[$User.Department]
        if ($GroupName) {
            try {
                Add-ADGroupMember -Identity $GroupName -Members $Username
                Write-Host "  [SUCCESS] Added to group: $GroupName" -ForegroundColor Green
            } catch {
                Write-Host "  [WARNING] Failed to add to group '$GroupName': $_" -ForegroundColor Yellow
            }
        }
        
        $SuccessCount++
        
    } catch {
        Write-Host "  [ERROR] Failed to create user: $_" -ForegroundColor Red
        $FailCount++
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Process Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Users Processed: $($Users.Count)" -ForegroundColor White
Write-Host "Successfully Created: $SuccessCount" -ForegroundColor Green
Write-Host "Failed: $FailCount" -ForegroundColor Red
Write-Host ""
Write-Host "Log file saved to: $LogPath" -ForegroundColor Yellow
Write-Host ""

Stop-Transcript

# PowerShell Active Directory User Onboarding Script

> A PowerShell script to automate the creation of new Active Directory users by reading from a CSV file. This project was built to practice my skills in PowerShell and AD automation.

## 🚀 Why I Built This

In my role as a Network Administrator, I provided remote desktop support for 100+ users. Manually provisioning each user is time-consuming and prone to errors.

I built this script to solve that problem. It demonstrates my ability to apply my PowerShell skills to automate a critical and repetitive IT task, saving time and ensuring every new user is configured correctly from day one.

## ✨ Features

* **Reads from CSV:** Ingests a `NewUsers.csv` file containing `FirstName`, `LastName`, `Department`, etc.
* **Creates AD User:** Automatically creates the new user in the correct Organizational Unit (OU) in Active Directory.
* **Sets Password:** Assigns a random, temporary password and forces a change on first login.
* **Adds to Groups:** Automatically adds the new user to default security groups based on their department.
* **Logs Everything:** Creates a transcript of all actions for troubleshooting.

## 🔧 Technologies Used

* **PowerShell**
* **Active Directory (AD)**
* **Windows 10/11** (as the host)

## ⚙️ How to Use

1. Clone the repository:
   ```bash
   git clone https://github.com/CTOBrien/AD-User-Onboarding-Script.git
   ```

2. Prepare your `NewUsers.csv` file in the same directory with the following format:
   ```csv
   FirstName,LastName,Department,JobTitle,Email
   John,Doe,IT,Systems Administrator,john.doe@company.com
   Jane,Smith,HR,HR Manager,jane.smith@company.com
   ```

3. Update the script variables to match your AD environment:
   - Domain name
   - OU paths
   - Security group names

4. Open PowerShell as an Administrator.

5. Run the script:
   ```powershell
   .\New-AD-Users.ps1
   ```

## 📋 Prerequisites

* Windows Server with Active Directory Domain Services installed
* PowerShell 5.1 or higher
* Active Directory PowerShell module
* Domain Administrator privileges
* Properly formatted CSV file

## 📊 CSV File Format

Your `NewUsers.csv` should include the following columns:

| Column | Description | Required |
|--------|-------------|----------|
| FirstName | User's first name | Yes |
| LastName | User's last name | Yes |
| Department | Department name (IT, HR, Sales, etc.) | Yes |
| JobTitle | User's job title | No |
| Email | User's email address | Yes |

## 🔐 Security Considerations

* Temporary passwords are randomly generated and meet complexity requirements
* Users must change password on first login
* All actions are logged with timestamps
* Script requires administrator privileges to execute

## 📝 Sample Output

```
[2024-11-15 10:30:15] Starting AD User Onboarding Process...
[2024-11-15 10:30:16] Successfully created user: John Doe (jdoe)
[2024-11-15 10:30:16] Added jdoe to group: IT-Users
[2024-11-15 10:30:17] Successfully created user: Jane Smith (jsmith)
[2024-11-15 10:30:17] Added jsmith to group: HR-Users
[2024-11-15 10:30:18] Process completed. 2 users created successfully.
```

## 🛠️ Troubleshooting

**Issue:** "Unable to contact domain controller"
* **Solution:** Verify network connectivity and domain controller availability

**Issue:** "Access denied"
* **Solution:** Ensure you're running PowerShell as Administrator with proper AD permissions

**Issue:** "User already exists"
* **Solution:** Check AD for existing accounts before running the script

## 🔮 Future Enhancements

- [ ] Add email notification upon user creation
- [ ] Support for multiple domains
- [ ] GUI interface for easier use
- [ ] Integration with HR systems
- [ ] Automated home directory creation
- [ ] Error handling improvements

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 👤 Author

**Cameron O'Brien**
* GitHub: [@CTOBrien](https://github.com/CTOBrien)
* LinkedIn: [Cameron O'Brien](https://www.linkedin.com/in/cameron-o-brien-08b73131b)

## 🙏 Acknowledgments

* Microsoft PowerShell Documentation
* Active Directory Administration Community
* IT Department colleagues for testing and feedback

---

⭐ If you find this project helpful, please consider giving it a star!

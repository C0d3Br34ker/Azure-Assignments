# Assignment-3: Create a simulator or automation that reads the email of a user and clicks the link provided (for now please use portal.azure.com as the target) from the email body along with other content. and enter the details of the user and log into the Azure portal.

# Scenario:-

    Suppose a user requests a password reset for their Azure account. The helpdesk admin processes the request and sends an email response containing the new temporary password, user principal name, and the portal URL. The task is to create a Python automation script that automatically reads this email, extracts the necessary information (like Login URl, Username and New Password), and displays it on the console. Additionally, the script will automate the login process using selenium to the Azure portal using the extracted credentials.

## Steps to Achieve the Task

### 1. Create the Python Script

- Email Automation:
  - Log in to the email account using IMAP.
  - Fetch emails based on specific criteria.
  - Read the email body to extract the portal URL, user principal name, and temporary password.
- Web Automation:
  - Start the Firefox browser using Selenium WebDriver.
  - Open the extracted portal URL.
  - Automate the login process (Use Random generated password to create a new login password) to Azure using the extracted credentials.

### 2. Extract Credentials from the Email

- Use regular expressions to parse the email body and extract the portal URL, user principal name, and temporary password.

### 3. Main Function Workflow

- Log in to the email account.
- Generate a Complex Password.
- Fetch and read emails.
- Check for the specific email containing the password reset information.
- Extract the necessary credentials.
- Display the extracted information on the console.
- Automate the login process to the Azure portal by creating a new password using Generated password.
- Log out from the email account and close the browser.

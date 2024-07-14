"""
Discription:- Create a simulator or automation that reads the email of a user and clicks the link provided (for now please use portal.azure.com as the target) from the email body along with other content. and enter the details of the user and log into the Azure portal.
"""

import imaplib
import email
from email.header import decode_header
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import re
import time
from PasswordGenerator import generate_random_password

class EmailAutomation:
    def __init__(self, email_user, email_pass):
        self.email_user = email_user
        self.email_pass = email_pass
        self.imap_server = "imap.gmail.com" # Here I'm using Gmail service. 
        self.imap_port = 993 
        self.mail = None

    def login_email(self):
        try:
            self.mail = imaplib.IMAP4_SSL(self.imap_server, self.imap_port)
            self.mail.login(self.email_user, self.email_pass)
            print("[+] Logged in to email successfully")
        except Exception as e:
            print(f"[-] Failed to login to email: {e}")

    def fetch_emails(self, search_criteria="ALL"):
        try:
            self.mail.select("inbox")
            status, messages = self.mail.search(None, search_criteria)
            email_ids = messages[0].split()
            return email_ids
        except Exception as e:
            print(f"[+] Failed to fetch emails: {e}")
            return []

    def read_email(self, email_id):
        try:
            # Fetch the email message by its ID
            status, msg_data = self.mail.fetch(email_id, "(RFC822)")
            # Ir will iterate through the all fetched email data
            for response_part in msg_data:
                if isinstance(response_part, tuple):
                    # Parse the email content
                    msg = email.message_from_bytes(response_part[1])
                    # Decode the email subject
                    subject, encoding = decode_header(msg["Subject"])[0]
                    if isinstance(subject, bytes):
                        subject = subject.decode(encoding if encoding else "utf-8")
                    # Check if the email has multipel part
                    if msg.is_multipart():
                        for part in msg.walk():
                            content_type = part.get_content_type()
                            content_disposition = str(part.get("Content-Disposition"))
                            try:
                                # Decode the email bady
                                body = part.get_payload(decode=True).decode()
                            except:
                                pass
                            # It will Check if the part has not an attachment
                            if "attachment" not in content_disposition:
                                # It will Check if the content type is text or not.
                                if content_type == "text/plain" or content_type == "text/html":
                                    return body
                    else:
                        # If the email is not multipart, decode the email body directly
                        body = msg.get_payload(decode=True).decode()
                        return body # Return the email body
        except Exception as e:
            print(f"Failed to read email: {e}")
            return ""

    def logout_email(self):
        try:
            self.mail.logout()
            print("[+] Logged out from email successfully")
        except Exception as e:
            print(f"[-] Failed to logout from email: {e}")

class WebAutomation:
    def __init__(self, driver_path):
        self.driver_path = driver_path
        self.driver = None

    def start_browser(self):
        try:
            self.driver = webdriver.Firefox()
            self.driver.maximize_window()
            print("[*] Browser started successfully")
        except Exception as e:
            print(f"[-] Failed to start browser: {e}")

    def open_url(self, url):
        try:
            self.driver.get(url)
            print(f"Opened URL: {url}")
        except Exception as e:
            print(f"[-] Failed to open URL: {e}")

    def login_azure(self, username, password, new_Password):
        try:
            wait = WebDriverWait(self.driver, 10) # Selenium will wait for a maximum of 10 seconds for an element matching the given criteria to be found. 
            # Provide Username
            email_field = wait.until(EC.presence_of_element_located((By.NAME, "loginfmt")))
            email_field.send_keys(username)
            email_field.send_keys(Keys.RETURN)

            time.sleep(2)
            # Provide Password
            password_field = wait.until(EC.presence_of_element_located((By.NAME, "passwd")))
            password_field.send_keys(password)
            password_field.send_keys(Keys.RETURN)
            
            time.sleep(2)
            
            # Update Password
            current_password = wait.until(EC.presence_of_element_located((By.ID, "currentPassword")))
            current_password.send_keys(password)
            new_password = wait.until(EC.presence_of_element_located((By.ID, "newPassword")))
            new_password.send_keys(new_Password)
            confirm_Password = wait.until(EC.presence_of_element_located((By.ID, "confirmNewPassword")))
            confirm_Password.send_keys(new_Password)
            confirm_Password.send_keys(Keys.RETURN)
            print(f"[*] The New password for User {username} is {new_Password}")

            time.sleep(2)

            # #By.ID(btnAskLater) //If it ask for Action Required, then we need to click on ask later button
            # stay_signed_in_button = wait.until(EC.presence_of_element_located((By.ID, "btnAskLater")))
            # stay_signed_in_button.click()

            time.sleep(2)
            # Click to Stay Signed In
            stay_signed_in_button = wait.until(EC.presence_of_element_located((By.ID, "idSIButton9")))
            stay_signed_in_button.click()
            print("[+] Logged in to Azure successfully")
            
            time.sleep(25)

            
        except Exception as e:
            print(f"[-] Failed to login to Azure: {e}")

    def close_browser(self):
        try:
            self.driver.quit()
            print("[*] Browser closed successfully")
        except Exception as e:
            print(f"[-] Failed to close browser: {e}")


def extract_credentials(email_body):
    try:
        portal_url = re.search(r'https?://[^\s]+', email_body).group()
        user_name = re.search(r'User Principal Name:\s*(\S+)', email_body).group(1)
        temp_password = re.search(r'Temporary Password:\s*(\S+)', email_body).group(1)
        return portal_url, user_name, temp_password
    except AttributeError:
        print("[-] Failed to extract credentials from the email body")
        return None, None, None

def main():
    email_user = input("Enter User Email Address: ") # Provide your email address
    email_pass = input("Enter User Password: ") #Provide your email password
    driver_path = "C:/Users/Asus/Desktop/Programming/Powershell/Azure_Security_Researcher/Ass-3/geckodriver.exe"

    email_automation = EmailAutomation(email_user, email_pass)
    web_automation = WebAutomation(driver_path)

    try:
        email_automation.login_email() #Try to login to the gmail server
        email_ids = email_automation.fetch_emails() # Fetch all the emails bu its ID's
        new_password = generate_random_password(12) # It will generate a Random Password of length 12

        for email_id in reversed(email_ids):
            email_body = email_automation.read_email(email_id)
            if "portal.azure.com" in email_body:
                portal_url, user_name, temp_password = extract_credentials(email_body)
                if portal_url and user_name and temp_password:
                  print(f"Login URL: {portal_url}\n,UserPrincipleName{user_name}\n,Temprary Password{temp_password}")
                  web_automation.start_browser()
                  web_automation.open_url(portal_url)
                  web_automation.login_azure(user_name, temp_password, new_password)
                break
    except KeyboardInterrupt:
        print("keybooard Interruption occure....")
        print('Quitting the process....')
    finally:
        email_automation.logout_email()
        web_automation.close_browser()

if __name__ == "__main__":
    main()

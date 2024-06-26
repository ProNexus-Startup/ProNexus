import os
from dotenv import load_dotenv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib

# Load environment variables from .env file
load_dotenv()

# Environment variables
email_address = os.getenv('EMAIL_ADDRESS')
email_password = os.getenv('PASSWORD')
smtp_server = "smtpout.secureserver.net"
smtp_port = 465  # SSL port

def send_password_reset_email(to_address):
    # Email subject and body
    subject = "Password Reset Request"
    body = (
        "Hey,\n\n"
        "We received a request to reset your password. Please click the link below to reset your password:\n\n"
        "https://yourwebsite.com/reset-password?email={}\n\n"
        "If you did not request a password reset, please contact us.\n\n"
        "Best regards,\n"
        "Roberto from ProNexus"
    ).format(to_address)

    # Create the email message
    msg = MIMEMultipart()
    msg['From'] = email_address
    msg['To'] = to_address
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))

    # Send the email
    try:
        # Establish a secure session with the server
        server = smtplib.SMTP_SSL(smtp_server, smtp_port)
        
        # Login to the email account
        server.login(email_address, email_password)
        
        # Send the email
        server.send_message(msg)
        print("Email sent successfully!")
        
    except Exception as e:
        print(f"Failed to send email: {e}")
        
    finally:
        # Terminate the SMTP session
        server.quit()

# Example usage
send_password_reset_email("rpupo63@gmail.com")

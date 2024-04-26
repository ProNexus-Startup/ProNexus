import requests
from email import message_from_string
from typing import List

# Function to get email content using Microsoft Graph API
def get_email_content(email_id: str, access_token: str) -> str:
    headers = {
        'Authorization': 'Bearer ' + access_token
    }
    response = requests.get(f'https://graph.microsoft.com/v1.0/me/messages/{email_id}', headers=headers)
    response.raise_for_status()
    return response.json().get('body', {}).get('content', '')

# Function to parse the email content using Python's email package
def parse_email_thread(raw_email_content: str) -> List[message_from_string]:
    # Parse the raw email content into an email message object
    message = message_from_string(raw_email_content)

    # List to store parsed emails
    emails = []

    # Check if the message is multipart (contains multiple emails)
    if message.is_multipart():
        for part in message.walk():
            # Ensure the part is a message/rfc822 content type (an embedded email)
            if part.get_content_type() == 'message/rfc822':
                emails.append(part.get_payload(0))
    else:
        emails.append(message)

    return emails

# Example usage
if __name__ == "__main__":
    email_id = 'your-email-id'
    access_token = 'your-access-token'
    
    # Get email content using Graph API
    email_content = get_email_content(email_id, access_token)
    
    # Parse the email thread into separate emails
    emails = parse_email_thread(email_content)
    
    # Print each email's sender and body
    for email in emails:
        print(f"Sender: {email['from']}")
        print(f"Body: {email.get_payload(decode=True)}\n")

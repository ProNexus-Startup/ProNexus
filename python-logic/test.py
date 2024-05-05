import email
from email import message_from_string
from email.header import decode_header
import webbrowser
import os
from dotenv import load_dotenv
import openai
from msal import ConfidentialClientApplication
import requests
import json
import time
import os.path
from exchangelib import Credentials, Account, Configuration, DELEGATE
import datetime
from typing import List, Optional
from bs4 import BeautifulSoup
import re

#region Constants
load_dotenv()
user_id_or_principal_name = os.getenv('EMAIL_ADDRESS')
tenant_id = os.getenv('TENANT_ID')
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:8080')
openai.api_key = os.getenv('OPENAI_API_KEY')
BACKEND_PASSWORD = os.getenv('BACKEND_PASSWORD')

expert_template = '''From the following email, return the values of each of the specified fields in the data format listed below for all experts specified in the email. If the expert is not specified by name, write None for those fields. You can find the project name in the subject. If this seems like an email without expert information, just return the list with a single item containing the phrase as a string "No Expert Found". Experts need to have an explicit name; this email can't just be describing the kind of expert desired by the email sender.


Return each field using the following structure:
  expert_data = {
    [field1] : [value1]
    [field2] : [value2]
    ...
  }  
  String "name";
  String "title";
  String "company";
  String "companyType";
  String "projectName"
  String "yearsAtCompany";
  String "description";
  String "geography";
  String "angle";screen
  String "availability";
  double "cost";
  List<Map<String, String>> "screening questions and answer";
  
  
  here is the email:
  
  '''

call_template = ''' From this list of experts, return only the id, as a string, of the expert that this email is most likely to be about.'''

company_info = {
    'thirdbridge': {
        'company': 'Thirdbridge',
        'phrase': 'This specialist is based'
    },
    'prosapient': {
        'company': 'Prosapient',
        'phrase': 'You can view all our profiles by following this link, no login required'
    },
    'dialecticanet': {
        'company': 'Dialectica',
        'phrase': 'Geographical areas does your company cover'
    },
    'colemanrg': {
        'company': 'Coleman',
        'phrase': 'To view full expert details and initiate scheduling'
    },
    'glgroup': {
        'company': 'GLG',
        'phrase': 'Usage & Compliance Policies: By making contact with Network Members'
    },
    'arbolus': {
        'company': 'Arbolus',
        'phrase': 'Please briefly describe your role and responsibilities'
    },
    'guidepoint': {
        'company': 'Guidepoint',
        'phrase': 'VIEW & SCHEDULE NOW'
    },
    'alphasights': {
        'company': 'Alphasights',
        'phrase': 'Button that says "view full profile"'
    }
}
#endregion

def read_emails():
    authority_url = f'https://login.microsoftonline.com/{tenant_id}'
    scope = ['https://graph.microsoft.com/.default']
    app = ConfidentialClientApplication(
        client_id,
        authority=authority_url,
        client_credential=client_secret,
    )

    token_response = app.acquire_token_for_client(scopes=scope)
    if "access_token" in token_response:
        access_token = token_response['access_token']
        # Set up API call with additional properties
        url = f'https://graph.microsoft.com/v1.0/users/{user_id_or_principal_name}/messages?$filter=isRead eq false&$select=subject,sender,toRecipients,hasAttachments,body'
        headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        emails = response.json().get('value', [])
        return emails
    else:
        print(f"Failed to retrieve emails. Status code: {response.status_code}")
        print(f"Error message: {response.text}")
        return None



def extract_emails(html_content):
    # Use BeautifulSoup to parse the HTML content
    soup = BeautifulSoup(html_content, 'html.parser')
    
    # Extract text from the parsed HTML
    text_content = soup.get_text()
    
    # Regular expression to find the email headers
    email_pattern = re.compile(r"(From:.*?)(?=From:|$)", re.DOTALL)
    
    # Find all emails using the pattern
    emails = email_pattern.findall(text_content)
    
    # Process each email
    for email in emails:
        from_line = re.search(r"From:.*", email)
        to_line = re.search(r"To:.*", email)
        subject_line = re.search(r"Subject:.*", email)
        
        # Print the details for each email
        print("From:", from_line.group(0) if from_line else "Not found")
        print("To:", to_line.group(0) if to_line else "Not found")
        print("Subject:", subject_line.group(0) if subject_line else "Not found")
        print("Email Content:")
        print(email)
        print("-" * 80)  # Separator for emails

# Example HTML content
html_content = """
<div>
    <p>From: Alice &lt;alice@example.com&gt;</p>
    <p>To: Bob &lt;bob@example.com&gt;</p>
    <p>Subject: Meeting Reminder</p>
    <p>Hello Bob, just a reminder about our meeting tomorrow.</p>
    <p>From: Charlie &lt;charlie@example.com&gt;</p>
    <p>To: Dana &lt;dana@example.com&gt;</p>
    <p>Subject: New Project</p>
    <p>Hi Dana, let's discuss our new project.</p>
</div>
"""

# Call the function with example content
extract_emails(html_content)



# Example usage:
emails = read_emails()
if emails:
    for email in emails:
        subject = sanitize_filename(email['subject'])
        # Assume 'body' contains the 'content' field with the actual email text
        individual_emails = extract_emails_from_thread(email['body']['content'])
        for i, individual_email in enumerate(individual_emails, 1):
            filename = f"{subject}_{i}.txt"
            with open(filename, 'w', encoding='utf-8') as file:
                file.write(individual_email)
            print(f"Written: {filename}")
else:
    print("No emails retrieved or failed to retrieve emails.")
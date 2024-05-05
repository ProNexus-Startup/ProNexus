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
from email_reply_parser import EmailReplyParser

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

#region Get Emails
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

def parse_emails_from_thread(text):
    email_message = EmailReplyParser.read(text)
    emails = []
    current_email = []

    # Go through each fragment and collect those that aren't hidden
    for fragment in email_message.fragments:
        if not fragment.hidden:
            current_email.append(fragment.content)
        elif fragment.headers and current_email:
            # When a header is found and we have collected some fragments, assume it's a new email
            emails.append('\n'.join(current_email))
            current_email = []

    # Add the last collected email if any fragments were collected after the last header
    if current_email:
        emails.append('\n'.join(current_email))

    return emails

#endregion

#region Get information for backend
def get_expert_info(email):
    email_body = email.get_payload(decode=True)
    subject = email['subject']
    edited_subject = f'Subject: {subject}\n'
    message = expert_template + edited_subject + str(email_body)
    
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": message}
            ]
        )
        expert_data_list = json.loads(response['choices'][0]['message']['content'])
        
        if isinstance(expert_data_list, list):
            # Manipulate data for each expert as necessary
            for expert_data in expert_data_list:
                if expert_data == "No Expert Found":
                    return None
                expert_data["screeningQuestions"] = expert_data.pop("screening questions and answer", [])
                expert_date["dateAddedExpert"] = datetime.datetime.now()
            return expert_data_list
        
    except json.JSONDecodeError:
        print("Failed to decode response as JSON")
    except Exception as e:
        print(f"An error occurred: {e}")
    return None

def get_call_info(email, user_email):
    if email.get('isCancelled', 'No information'):
        return None

    experts = get_from_backend(user_email, 'experts')

    email_body = email.get_payload(decode=True)
    message = call_template + str(experts) + str(email_body)
    
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": message}
            ]
        )
        expert = json.loads(response['choices'][0]['message']['content'])        
    except json.JSONDecodeError:
        print("Failed to decode response as JSON")
    except Exception as e:
        print(f"An error occurred: {e}")  

    call = None

    for expert in experts:
        if expert['expertId'] == expert_id:
            call = expert

    if call == None:
        print("chatgpt error")
        return None

    call["meetingStartDate"] =  email.get('start', {}).get('dateTime', 'No Start Time')
    call["meetingEndDate"] = email.get('end', {}).get('dateTime', 'No End Time')
    return call
#endregion

#region Backend Interaction
def send_to_backend(data, token, id, path, company=None):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}',
    },
    payload = json.dumps(data)
    response = requests.post(f'{BACKEND_URL}/{path}', headers=headers, data=payload)
    if response.status_code == 200:
        print("Expert added successfully!")
        mark_email_read(id)
    else:
        print(f"Failed to add expert. Status code: {response.status_code}")
        print(f"Response: {response.text}")

def get_from_backend(user_email, path):
    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {BACKEND_PASSWORD+user_email}',
    },
    url = f'{BACKEND_URL}/{path}'
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        experts = json.loads(response.body)
        return experts
    else:
        print(f"Failed to add expert. Status code: {response.status_code}")
        print(f"Response: {response.text}")
        return none

def mark_email_read(id):
    mark_read_url = f'https://graph.microsoft.com/v1.0/users/{user_id_or_principal_name}/messages/{id}'
    mark_read_data = {'isRead': True}
    mark_response = requests.patch(mark_read_url, headers=headers, json=mark_read_data)    
#endregion

#region route emails
def route_data(email):    
    for key, value in email.items():
        print(key, value)
    
    try:
        body = email['body']
    except KeyError:
        print("Email body not accessible")
        return "none"
    
    sender = email['from']
    print("sender here")
    print(sender)
    try:
        domain_part = sender.split('@')[1]
        domain = '.'.join(domain_part.split('.')[:-1])
    except IndexError:
        print("Invalid email format")
        return "none"

    if domain not in company_info:
        print("Email not relevant")
        return "none"

    if email.get('isMeeting') or email.get('meetingMessageType') in ['meetingRequest', 'meetingCancelled']:
        return "call"

    # Safe access to company_info using domain
    if domain in company_info:
        phrase = company_info[domain].get('phrase', '')
        company = company_info[domain].get('company', '')
        if phrase not in body:
            print("Keyphrase not detected")
            return "none"
        return company
    else:
        print("Domain not found in company info")
        return "none"
#endregion

# Read email and process
def primary_func(backend_password: str):

    email_list = read_emails()
    if email_list is None:
        return None
    # Fix below
    route = route_data(email_dict)
    if route == "call":
        call_info = get_call_info(email=email_dict)
        if call_info:
            send_to_backend(
                data=call_info,
                token=backend_password + email['from'],
                path='make-call'
            )
    elif route == "none":
        continue
    else:
        expert_data = get_expert_info(email=parsed_email)
        if expert_data != "No Expert Found":
            for expert in expert_data:
                send_to_backend(
                    data=expert,
                    company=route,
                    token=backend_password + email_data['sender']['address'],
                    id=email_data['id'],
                    path="make-expert"
                )


def main():
    try:
        while True:
            primary_func(backend_password=BACKEND_PASSWORD)
            #time.sleep(60)
    except KeyboardInterrupt:
        print("Program stopped manually.")

if __name__ == "__main__":
    main()
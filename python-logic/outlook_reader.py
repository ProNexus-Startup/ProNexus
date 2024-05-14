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
import re
from bs4 import BeautifulSoup
import subprocess
import json

#region Constants
load_dotenv()
user_id_or_principal_name = os.getenv('EMAIL_ADDRESS')
tenant_id = os.getenv('TENANT_ID')
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:8080')
openai.api_key = os.getenv('OPENAI_API_KEY')
BACKEND_PASSWORD = os.getenv('BACKEND_PASSWORD')

expert_template = '''From the following email, return the values of each of the specified fields in the data format listed below for all experts specified in the email. If the expert is not specified by name, write None for those fields. If this seems like an email without expert information, just return the list with a single item containing the phrase as a string "No Expert Found". Experts need to have an explicit name; this email can't just be describing the kind of expert desired by the email sender.


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
        'phrase': 'view full profile'
    }
}
#endregion

#region Get Email Information
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

def transform_to_text(html):
    json_html = json.dumps(html)

    # Call the JavaScript file using Node.js
    result = subprocess.run(['node', 'html-to-text.js', json_html], capture_output=True, text=True)

    # Get the output and handle potential errors
    if result.returncode == 0:
        clean_text = result.stdout.strip().replace('> ', '')
        return clean_text
        #return result.stdout.strip()
    else:
        raise Exception(f"Error: {result.stderr}")

def split_emails_by_header(input_string):
    # Split the string using a regular expression to handle different cases of "From:"
    parts = re.split(r'(?i)from:', input_string)
    
    # The first element doesn't start with "From:", so we keep it as is.
    result = [parts[0]]
    matches = re.findall(r'(?i)(from:)', input_string)
    for i, part in enumerate(parts[1:]):
        prefix = matches[i] if i < len(matches) else "From:"
        result.append(str(prefix + part))
    
    return result

def split_emails_by_statement(input_string):
    # Compile the regex pattern to match headers starting with 'On' and ending with 'wrote:'
    pattern = re.compile(r'(On.*?wrote:)', flags=re.DOTALL)

    # Split the input string based on the pattern, capturing the delimiters
    parts = re.split(pattern, input_string)
    result = []

    if parts:
        # Keep the first chunk before the first delimiter as the first element
        initial_segment = parts[0].strip()
        # Collect the remaining parts for reversal
        subsequent_parts = []

        # Iterate over the remaining parts to combine the header and the corresponding message
        for i in range(1, len(parts), 2):
            if i + 1 < len(parts):
                combined_part = parts[i].strip() + '\n\n' + parts[i + 1].strip()
                subsequent_parts.append(combined_part)

        # Reverse the list of subsequent parts
        subsequent_parts.reverse()

        # Construct the final result by appending the initial segment followed by the reversed subsequent parts
        result.append(initial_segment)
        result.extend(subsequent_parts)

    return result[::1]

def make_dict_by_headers(email_content):
    # Dictionary to store the extracted information
    info = {'subject': None, 'from': None, 'date': None, 'body': None}
    
    # Split the input string into lines
    lines = email_content.split('\n')
    
    # Variables to help capture the body
    headers = ("From:", "To:", "Subject:", "Cc:", "Date:", "Sent:")
    body_lines = []
    capture_body = False
    
    # Iterate through each line to find relevant information and capture the body
    for line in lines:
        line = line.strip()  # Remove any leading/trailing whitespace
        if any(line.startswith(header) for header in headers):
            header_content = line.split(':', 1)[1].strip()  # Get content after header
            if line.startswith("Subject:"):
                info['subject'] = header_content
            elif line.startswith("From:"):
                # Using regex to extract email between "mailto:" and "\\"
                match = re.search(r'mailto:([^\\]*)\\', header_content)
                if match:
                    info['from'] = match.group(1).strip()
                else:
                    info['from'] = header_content  # Fallback to the whole line if pattern not found
            elif line.startswith("Date:") or line.startswith("Sent:"):
                info['date'] = header_content
            capture_body = False  # Reset when hitting another header
        else:
            if not capture_body:
                body_lines.append(line)  # Only append if capturing body

    # Join all body lines to form the complete body text
    info['body'] = '\n'.join(body_lines).strip()
    
    return info

def make_dict_by_statement(email_content):
    # Improved regex to find the date and time, accounting for potential variations
    date_pattern = r"On\s+(.+? [AP]M)"
    date_match = re.search(date_pattern, email_content, re.UNICODE)
    date_info = date_match.group(1) if date_match else None
    
    # Improved regex to find the email address, ignoring potential noise around it
    email_pattern = r"mailto:(\S+?)\\"
    email_match = re.search(email_pattern, email_content)
    email_info = email_match.group(1) if email_match else None
    
    return date_info, email_info
#endregion

#region Get Information for backend
def get_expert_info(email_body):
    message = expert_template + str(email_body)
    
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
    backend_headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}',
    },
    payload = json.dumps(data)
    response = requests.post(f'{BACKEND_URL}/{path}', headers=backend_headers, data=data)
    if response.status_code == 200:
        print("Expert added successfully!")
        mark_email_read(id)
    else:
        print(f"Failed to add expert. Status code: {response.status_code}")
        print(f"Response: {response.text}")

def get_from_backend(user_email, path):
    backend_headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {BACKEND_PASSWORD+user_email}',
    },
    url = f'{BACKEND_URL}/{path}'
    response = requests.get(url, headers=backend_headers)
    if response.status_code == 200:
        experts = json.loads(response.body)
        return experts
    else:
        print(f"Failed to add expert. Status code: {response.status_code}")
        print(f"Response: {response.text}")
        return none

def mark_email_read(id):
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

    mark_read_url = f'https://graph.microsoft.com/v1.0/users/{user_id_or_principal_name}/messages/{id}'
    mark_read_data = {'isRead': True}
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    mark_response = requests.patch(mark_read_url, headers=headers, json=mark_read_data)    
#endregion

#region route emails
def route_data(email):    
    body = email['body']
    sender = email['from']
    if sender is None or sender.find('@') == -1:
        print("missing sender")
        return
    if body is None:
        print("missing body")
        return
    domain_part = sender.split('@')[1]
    domain = '.'.join(domain_part.split('.')[:-1])

    if domain not in company_info:
        print("Email not relevant")
        return None

    if email.get('isMeeting') or email.get('meetingMessageType') in ['meetingRequest', 'meetingCancelled']:
        print("routed to call")
        return "call"

    # Safe access to company_info using domain
    if domain in company_info:
        phrase = company_info[domain].get('phrase', '')
        company = company_info[domain].get('company', '')
        print("routed to expert")
        return company
    else:
        print("Domain not found in company info")
        return "none"
#endregion

def primary_func(backend_password: str):
    email_list = read_emails()
    if email_list is None:
        return None

    for email in email_list:
        text = transform_to_text(email['body']['content'])
        header_split = split_emails_by_header(text)
        sender = email['sender']['emailAddress']['address']

        for splita in header_split:
            statement_split = split_emails_by_statement(splita)
            for splitb in statement_split:
                email_dict = make_dict_by_headers(splitb)
                if email_dict['date'] == None:
                    email_dict['date'] = make_dict_by_statement(splitb)[0]
                if email_dict['from'] == None:
                    email_dict['from'] = make_dict_by_statement(splitb)[1]
                if email_dict['subject'] == None:
                    email_dict['subject'] = email['subject']
                print("Email dict shit worked")
                print(email_dict)

                route = route_data(email_dict)
                
                if route == "call":
                    call_info = get_call_info(email=email_dict)
                    if call_info:
                        send_to_backend(
                            data=call_info,
                            token=backend_password + sender,
                            path='make-call'
                        )

                elif route == None:
                    continue

                elif route in [info['company'] for info in company_info.values()]:
                    print(route)
                    expert_data = get_expert_info(email=email_dict['body'])
                    if expert_data != "No Expert Found":
                        for expert in expert_data:
                            send_to_backend(
                                data=expert,
                                company=route,
                                token=backend_password + sender,
                                id=email['id'],
                                path="make-expert"
                            )
            mark_email_read(email['id'])

def main():
    try:
        while True:
            primary_func(backend_password=BACKEND_PASSWORD)
            #time.sleep(60)
    except KeyboardInterrupt:
        print("Program stopped manually.")

if __name__ == "__main__":
    main()

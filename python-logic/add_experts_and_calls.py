import email
from email import message_from_string
from email.header import decode_header
import webbrowser
import os
from dotenv import load_dotenv
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
from openai import OpenAI
from ics import Calendar
from datetime import datetime

#region Constants
load_dotenv()
user_id_or_principal_name = os.getenv('EMAIL_ADDRESS')
tenant_id = os.getenv('TENANT_ID')
client_id = os.getenv('CLIENT_ID')
client_secret = os.getenv('CLIENT_SECRET')
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:8080')
BACKEND_PASSWORD = os.getenv('BACKEND_PASSWORD')
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

def expert_template(angles):
    string1 = '''
    From the email provided, extract detailed information for each expert mentioned and return the data in JSON format. If no expert's name is specified or if the email does not contain specific expert details, return JSON data with a single item: {"No Expert Found": true}. Finally, choose an angle from the list of provided angles below:
    '''

    string2 = '''
    For each expert, present the data in the following structured format:

    {
    "expert_data": [
        {
        "name": string,
        "angle": string //choose based on the provided list of angles
        "profession": string or null,
        "company": string or null,
        "companyType": string or null,
        "startDate": string or null,
        "description": string or null,
        "geography": string or null,
        "angle": string or null,
        "cost": float,
        "aiAnalysis": string, //write two sentences detailing your opinion on the quality of this expert
        "aiAssessment": int, //provide a score from 1 to 100 on the quality of this expert
        "availabilities": [
            {
            "start": string, // ISO 8601 format
            "end": string, // ISO 8601 format
            "timeZone": string // Timezone in IANA Time Zone Database format
            }
        ],
        "screeningQuestionsAndAnswers": [
            {
            "question": string,
            "answer": string
            }
        ],
        "employmentHistory": [
            {
            "role": string,
            "company": string,
            "startDate": string, // ISO 8601 format
            "endDate": string or null // ISO 8601 format or null
            }
        ]
        }
    ]
    }

    Here is an example of a response I want. Do not include anything beyond what the example shows. Copy the format provided. Remember to put all the relevant information within 'expert_data'. The only variables you should have are name, profession, company, companyType, startDate, description, geography, angle, cost, availabilities, screeningQuestionsAndAnswers, and employmentHistory:

    {
    "expert_data": [
        {
        "name": "Roger Gregg",
        "angle": "Managers and competitors"
        "profession": "National Accounts Executive",
        "company": "Johns Manville",
        "companyType": null,
        "startDate": "2017-06-01T00:00:00Z",
        "description": "Roger is currently National Accounts Executive at Johns Manville, serving since June 2017. Previously, he held the position of National Account Executive at Hearth & Home Technologies (June 2015 - June 2017) and was the Director of Strategy, National Accounts (Sales), Operations, and Product at Sears Holdings Corporation (June 2011 - April 2015).",
        "geography": "Based in USA",
        "angle": "Managers and Competitors",
        "cost": 0.0,
        "aiAnalysis": This is a very good expert for the angle he relates to as he has only been at Johns Manville for 7 years. His only flaw is his previous positions had nothing to do with the angle.
        "aiAssessment": int, //provide a score from 1 to 100 on the quality of this expert
        "availabilities": [
            {
            "start": "2024-06-12T09:00:00Z",
            "end": "2024-06-12T12:00:00Z",
            "timeZone": "America/New_York"
            },
            {
            "start": "2024-06-13T14:00:00Z",
            "end": "2024-06-13T18:00:00Z",
            "timeZone": "Europe/London"
            }
        ],
        "screeningQuestionsAndAnswers": [
            {
            "question": "What is your experience with project management?",
            "answer": "I have over 5 years of experience managing various projects in the tech industry, including software development and IT infrastructure projects."
            },
            {
            "question": "Can you describe a time when you had to handle a difficult client?",
            "answer": "In my previous role, I had a client who was unhappy with the progress of their project. I arranged a meeting to discuss their concerns, adjusted the project plan to meet their needs, and maintained regular updates to ensure their satisfaction."
            },
            {
            "question": "How do you prioritize your tasks when managing multiple projects?",
            "answer": "I prioritize tasks based on their deadlines and impact on the project's overall success. I use project management tools to track progress and ensure that critical tasks are completed on time."
            }
        ],
        "employmentHistory": [
            {
            "role": "Software Engineer",
            "company": "Tech Solutions Inc.",
            "startDate": "2018-01-15T00:00:00Z",
            "endDate": "2020-06-30T00:00:00Z"
            },
            {
            "role": "Senior Developer",
            "company": "Innovative Apps LLC",
            "startDate": "2020-07-01T00:00:00Z",
            "endDate": "2022-09-15T00:00:00Z"
            },
            {
            "role": "Project Manager",
            "company": "Creative Tech Co.",
            "startDate": "2022-10-01T00:00:00Z",
            "endDate": null
            }
        ]
        }
    ]
    }

    Please format all data as JSON objects and arrays as shown, without adding any additional context or explanatory text. Do not include fields such as "consulting_firm_name" or "project_description". Use the variable name "expert_data" exactly as shown.
    '''

    if angles is not None:
        message = string1 + angles + string2
    else:
        message = string1 + '[Soap Decision Makers in the Northeast, Cleaning Supply Workers in the South, Other]' + string2 
    return message


call_template = '''From this list of experts, return only the id, as a string, of the expert that this email is most likely to be about. If it is about none, return null.'''

company_info = {
    'thirdbridge': {
        'company': 'Thirdbridge',
        'phrases': ['Employment History:']
    },
    'prosapient': {
        'company': 'Prosapient',
        'phrases': ['You can view all our profiles by following this link, no login required']
    },
    'dialecticanet': {
        'company': 'Dialectica',
        'phrases': ['New Profile', "Rate for 60' call", "Availabilities"]
    },
    'colemanrg': {
        'company': 'Coleman',
        'phrases': ['View Details']
    },
    'glgroup': {
        'company': 'GLG',
        'phrases': ['Usage & Compliance Policies: By making contact with Network Members']
    },
    'arbolus': {
        'company': 'Arbolus',
        'phrases': ['Please briefly describe your role and responsibilities']
    },
    'guidepoint': {
        'company': 'Guidepoint',
        'phrases': ['Advisor #', 'VIEW & SCHEDULE NOW', 'Click an available time below to request a consultation start']
    },
    'alphasights': {
        'company': 'Alphasights',
        'phrases': ['Full List of Profiles Here']
    },
    'cornell': {
        'company': 'Cornell',
        'phrases': ['Profiles below for review']
    }

}

#endregion

def process_meeting_attachment(email):
    """
    Processes an email to detect and read meeting attachment and prints meeting information.
    Assumes the meeting attachment is an .ics file.
    """
    print("Starting process_meeting_attachment")
    
    # Check if the email has attachments
    if email.get('hasAttachments', False):
        print("Email has attachments")
        
        # Extract the attachments
        attachments = email.get('attachments', [])
        print(f"Found {len(attachments)} attachments")
        
        for attachment in attachments:
            print(f"Processing attachment: {attachment['name']}")
            
            if attachment['name'].endswith('.ics'):
                print("Found .ics attachment")
                
                # Create a temporary file to save the attachment
                with tempfile.NamedTemporaryFile(delete=False, suffix=".ics") as temp_file:
                    print("Creating temporary file for the attachment")
                    temp_file.write(base64.b64decode(attachment['contentBytes']))  # assuming the attachment content is base64 encoded
                    temp_filename = temp_file.name
                    print(f"Temporary file created: {temp_filename}")
                
                # Read the .ics file using ics library
                try:
                    print("Reading the .ics file")
                    with open(temp_filename, 'r') as f:
                        calendar = Calendar(f.read())
                        print("Successfully read the .ics file")
                finally:
                    # Cleanup temporary file
                    print(f"Removing temporary file: {temp_filename}")
                    os.remove(temp_filename)

                # Process the first event in the calendar (assuming only one meeting)
                for event in calendar.events:
                    print("Processing event from the calendar")
                    start_time = event.begin.datetime
                    end_time = event.end.datetime
                    
                    # Format the dates
                    start_time_str = start_time.strftime('%Y-%m-%dT%H:%M:%S')
                    end_time_str = end_time.strftime('%Y-%m-%dT%H:%M:%S')
                    
                    print(f"Meeting start time: {start_time_str}")
                    print(f"Meeting end time: {end_time_str}")
                    
                    return [start_time_str, end_time_str]
    else:
        print("Email does not have attachments")
        
    print("No .ics attachment found")
    return None #['2023-06-11T15:04:05Z', '2024-12-25T09:30:00-07:00']

#region Get Email Information
def read_emails():
    print("Reading emails...")
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
        print("Access token acquired.")
        # Set up API call with additional properties
        url = f'https://graph.microsoft.com/v1.0/users/{user_id_or_principal_name}/messages?$filter=isRead eq false&$select=subject,sender,toRecipients,hasAttachments,body'
        headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        print("Emails retrieved successfully.")
        emails = response.json().get('value', [])
        return emails
    else:
        print(f"Failed to retrieve emails. Status code: {response.status_code}")
        print(f"Error message: {response.text}")
        return None

def transform_to_text(html):
    print("Transforming HTML to text...")
    json_html = json.dumps(html)

    # Call the JavaScript file using Node.js
    result = subprocess.run(['node', 'html-to-text.js', json_html], capture_output=True, text=True)

    # Get the output and handle potential errors
    if result.returncode == 0:
        clean_text = result.stdout.strip().replace('> ', '')
        print("HTML transformed to text successfully.")
        return clean_text
    else:
        raise Exception(f"Error: {result.stderr}")

def split_emails_by_header(input_string):
    print("Splitting emails by header...")
    # Split the string using a regular expression to handle different cases of "From:"
    parts = re.split(r'(?i)from:', input_string)

    # The first element doesn't start with "From:", so we keep it as is.
    result = [parts[0]]
    matches = re.findall(r'(?i)(from:)', input_string)
    for i, part in enumerate(parts[1:]):
        prefix = matches[i] if i < len(matches) else "From:"
        result.append(str(prefix + part))

    print("Emails split by header successfully.")
    return result

def split_emails_by_statement(input_string):
    print("Splitting emails by statement...")
    # Compile the regex pattern to match headers starting with 'On' and ending with 'wrote:', with a maximum of 50 characters in between
    pattern = re.compile(r'(On.{0,150}?wrote:)', flags=re.DOTALL)

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

    print("Emails split by statement successfully.")
    return result[::1]

def make_dict_by_headers(email_content):
    print("Creating dictionary from headers...")
    # Dictionary to store the extracted information
    info = {'subject': None, 'from': None, 'date': None, 'body': None}

    # Normalize spaces in the email content
    email_content = email_content.replace('\xa0', ' ')

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
    print("Dictionary created from headers successfully.")
    return info

def make_dict_by_statement(email_content):
    print("Creating dictionary from statement...")
    # Improved regex to find the date and time, accounting for potential variations
    date_pattern = r"On\s+(.+? [AP]M)"
    date_match = re.search(date_pattern, email_content, re.UNICODE)
    date_info = date_match.group(1) if date_match else None

    # Improved regex to find the email address, ignoring potential noise around it
    email_pattern = r"mailto:(\S+?)\\"
    email_match = re.search(email_pattern, email_content)
    email_info = email_match.group(1) if email_match else None

    print("Dictionary created from statement successfully.")
    return date_info, email_info
#endregion

#region Interpret Information Using ChatGPT
def get_expert_info(email_body, company, user_email):
    print("Getting expert information...")
    angles = get_from_backend(user_email, 'angles')

    message = expert_template(angles) + str(email_body)

    response = client.chat.completions.create(
        model="gpt-4o",
        response_format={ "type": "json_object" },
        messages=[
            {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
            {"role": "user", "content": message}
        ]
    )

    data = response.choices[0].message.content
    clean_data = data.replace("```", "").replace("json", "")

    expert_data_list = json.loads(clean_data)
    for expert in expert_data_list['expert_data']:
        expert['expertNetworkName'] = company
        expert['status'] = 'Available'
   
    print("Expert information retrieved successfully.")
    print(expert_data_list)
    return expert_data_list

def get_call_info(email, user_email):
    print("Getting call information...")

    experts = get_from_backend(user_email, 'experts')
    print("Experts retrieved from backend.")

    email_body = email['body']
    message = call_template + str(experts) + str(email_body)

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            response_format={ "type": "json_object" },
            messages=[
                {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
                {"role": "user", "content": message}
            ]
        )
        data = response.choices[0].message.content
        clean_data = data.replace("```", "").replace("json", "")
        expert = json.loads(clean_data)  # Ensure the JSON content is cleanly loaded
        print("Call information retrieved successfully.")

        # Extract the expert ID as a string
        expert_id = expert.get('id', '')

        payload = {
            "availableExpertId": expert_id,  # Ensure this is a string
            "meetingStartDate": email['meeting_object'][0],
            "meetingEndDate": email['meeting_object'][1]
        }
        return payload

    except json.JSONDecodeError:
        print("Failed to decode response as JSON")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None

    call = None

    for exp in experts:
        if exp['expertId'] == expert['expertId']:
            call = exp

    if call is None:
        print("ChatGPT error: No matching expert found.")
        return None

    call["meetingStartDate"] = email.get('start', {}).get('dateTime', 'No Start Time')
    call["meetingEndDate"] = email.get('end', {}).get('dateTime', 'No End Time')
    return call

#endregion

#region Backend Interaction
def send_to_backend(data, token, path, json):
    print(f"Sending data to backend. Payload: {data}")
    backend_headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    response = requests.post(f'{BACKEND_URL}{path}', headers=backend_headers, data=data, json=json)
    if response.status_code == 200:
        print("Data sent to backend successfully.")
    else:
        print(f"Failed to send data to backend. Status code: {response.status_code}")
        print(f"Response: {response.text}")

def get_from_backend(user_email, path):
    print(f"Retrieving data from backend for user: {user_email}")
    backend_headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {BACKEND_PASSWORD+user_email}'
    }
    url = f'{BACKEND_URL}{path}'
    response = requests.get(url, headers=backend_headers)
    if path == 'experts' and response.status_code == 200:
        experts = response.json()
        print("Data retrieved from backend successfully.")
        return experts
    elif path == 'angles' and response.status_code == 200:
        angles = response.json()
        print("Data retrieved from backend successfully.")
        return angles
    else:
        print(f"Failed to retrieve data from backend. Status code: {response.status_code}")
        print(f"Response: {response.text}")
        return None

def mark_email_read(id):
    print(f"Marking email as read. Email ID: {id}")
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
        print("Access token acquired for marking email as read.")
        # Set up API call with additional properties
        url = f'https://graph.microsoft.com/v1.0/users/{user_id_or_principal_name}/messages?$filter=isRead eq false&$select=subject,sender,toRecipients,hasAttachments,body'
        headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}

    mark_read_url = f'https://graph.microsoft.com/v1.0/users/{user_id_or_principal_name}/messages/{id}'
    mark_read_data = {'isRead': True}
    headers = {'Authorization': f'Bearer {access_token}', 'Content-Type': 'application/json'}
    mark_response = requests.patch(mark_read_url, headers=headers, json=mark_read_data)
    if mark_response.status_code == 200:
        print("Email marked as read successfully.")
    else:
        print(f"Failed to mark email as read. Status code: {mark_response.status_code}")
        print(f"Response: {mark_response.text}")
#endregion

#region route emails
def route_data(email):
    print("Routing data...")
    body = email['body']
    sender = email['from']
    if sender is None or sender.find('@') == -1:
        print("Missing sender")
        return
    if body is None:
        print("Missing body")
        return
    domain_part = sender.split('@')[1]
    domain = '.'.join(domain_part.split('.')[:-1])

    if domain not in company_info:
        print("Email not relevant")
        return None

    print(email['meeting_object'])

    if email['meeting_object'] is not None:
        print("Routed to call")
        return "call"

    # Safe access to company_info using domain
    if domain in company_info:
        phrases = company_info[domain].get('phrases', [])
        company = company_info[domain].get('company', '')

        # Check if any of the phrases are present in the body of the email
        if any(phrase in body for phrase in phrases):
            print("Routed to expert")
            return company
        else:
            print("Phrase not found in email body")
            return "none"
    else:
        print("Domain not found in company_info")
        return "none"
#endregion

def primary_func(backend_password: str):
    print("Starting primary function...")
    email_list = read_emails()
    meeting_object = None
    if email_list is None:
        print("No emails to process.")
        return None

    for email in email_list:
        meeting_object = process_meeting_attachment(email)
        print(meeting_object)

        if meeting_object is not None:
            print("Meeting object identified.")

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
                email_dict['meeting_object'] = meeting_object
                print("Email dictionary created successfully.")

                route = route_data(email_dict)

                if route == "call":
                    call_info = get_call_info(email=email_dict, user_email=sender)
                    if call_info:
                        send_to_backend(
                            json=call_info,
                            token=backend_password + sender,
                            path='make-call',
                            data = None
                        )

                elif route == None:
                    continue

                elif route in [info['company'] for info in company_info.values()]:
                    print(route)
                    expert_list = get_expert_info(email_body=email_dict['body'], company=route, user_email=sender)
                    if expert_list == "No Expert Found" or expert_list is None or 'expert_data' not in expert_list:
                        print(f'value of no expert: {expert_list == "No Expert Found"}')
                        print(f'value of expert list being non: {expert_list is None}')
                        print(f'value of comp not in list: {'expert_data' not in expert_list}')
                        continue
                    for expert in expert_list['expert_data']:
                        total_entries = len(expert)
                        none_count = sum(1 for value in expert.values() if value is None)
                        if (none_count > total_entries / 2):
                            print("routed away from main")
                            continue
                        send_to_backend(
                            data=json.dumps(expert),
                            token=backend_password + sender,  # Ensure these variables are correctly defined and used
                            path="make-expert",
                            json=None
                        )
        mark_email_read(email['id'])  # This is outside the loop, make sure this is the intended behavior

def main():
    try:
        while True:
            primary_func(backend_password=BACKEND_PASSWORD)
            print("Sleeping for 60 seconds...")
            #time.sleep(60)
    except KeyboardInterrupt:
        print("Program stopped manually.")

if __name__ == "__main__":
    main()

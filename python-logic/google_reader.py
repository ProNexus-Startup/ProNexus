import openai
import requests
import json
import imaplib
import email
from email.header import decode_header
import time
import os
from dotenv import load_dotenv
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import base64

# If modifying these scopes, delete the file token.json.
# Constants
load_dotenv()
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]
EMAIL = os.getenv('EMAIL_ADDRESS')
PASSWORD = os.getenv('EMAIL_PASSWORD')
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:8080/')
openai.api_key = os.getenv('OPENAI_API_KEY')
print(EMAIL)
print(PASSWORD)

def get_gmail_service():
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    service = build('gmail', 'v1', credentials=creds)
    return service

SCRIPT_TEMPLATE = '''From the following email, return the value of each of the following fields in the data format listed below for the expert specified in the email. If not specified, write None (the python equivalent of a null value).

Return each field using the following structure:
  expert_date = {
    [field1] : [value1]
    [field2] : [value2]
    ...
  }  
  String "name";
  String "title";
  String "company";
  String "yearsAtCompany";
  String "description";
  String "geography";
  String "angle";screen
  String "availability";
  double "cost";
  List<Map<String, String>> "screening questions and answer";
  
  
  here is the email:
  
  '''

def extract_expert_data(email_body):
    message = SCRIPT_TEMPLATE + email_body
    try:
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": message}
            ]
        )
        # Assuming the output format is JSON-like or can be parsed
        expert_data = json.loads(response['choices'][0]['message']['content'])
        # Manipulate data as necessary
        expert_data["screeningQuestions"] = expert_data.pop("screening questions and answer", [])
        return expert_data
    except json.JSONDecodeError:
        print("Failed to decode response as JSON")
    except Exception as e:
        print(f"An error occurred: {e}")
    return None

def process_emails():
    service = get_gmail_service()
    try:
        # Fetch unread messages from the user's inbox
        results = service.users().messages().list(userId='me', labelIds=['INBOX', 'UNREAD']).execute()
        messages = results.get('messages', [])

        if not messages:
            print('No unread messages found.')
            return

        for message in messages:
            msg_id = message['id']
            msg = service.users().messages().get(userId='me', id=msg_id, format='raw').execute()
            msg_str = base64.urlsafe_b64decode(msg['raw']).decode('utf-8')
            msg = email.message_from_string(msg_str)

            subject = decode_header(msg["subject"])[0][0]
            if isinstance(subject, bytes):
                subject = subject.decode()

            email_body = ""
            if msg.is_multipart():
                for part in msg.walk():
                    if part.get_content_type() == 'text/plain' and part.get("Content-Disposition") is None:
                        email_body += part.get_payload(decode=True).decode()
            else:
                email_body = msg.get_payload(decode=True).decode()

            if email_body:
                expert_data = extract_expert_data(email_body)
                send_to_backend(expert_data, msg.get("from"))

    except HttpError as error:
        print(f'An error occurred: {error}')
        print(error)


def send_to_backend(data, sender):
    headers = {
        "Authorization": sender,
        "Content-Type": "application/json"
    }
    payload = json.dumps(data)
    response = requests.post(BACKEND_URL, headers=headers, data=payload)
    if response.status_code == 200:
        print("Expert added successfully!")
    else:
        print(f"Failed to add expert. Status code: {response.status_code}")
        print(f"Response: {response.text}")

def main():
    try:
        while True:
            process_emails()
            time.sleep(60)
    except KeyboardInterrupt:
        print("Program stopped manually.")

if __name__ == "__main__":
    main()


        # Extract the expert_data variable from the response
    #for message in response['choices'][0]['message']['content'].split('\n'):
    #    if "expert_data = {" in message:
    #        expert_data = eval(message.split('=', 1)[1].strip())
    #        return expert_data

#    return None
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
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:8080/')
BACKEND_PASSWORD = os.getenv('BACKEND_PASSWORD')
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))


message_template = '''
From the following outreach message to networks, extract detailed information for the project and return the data in JSON format. If no project's name is specified or if the mesage does not contain specific project details, return JSON data with a single item: {"No Project Found": true}:

    {
    "project": [
        {
        "name": string,
        "startDate": string or null, // ISO 8601 format
        "endDate": string or null, // ISO 8601 format
        "angles": [
            {
            "name": string,
            "description": string,
            "callLength": int, // expected length of calls in minutes
            "geoFocus": []string,
            "exampleCompanies": []string,
            "exampleTitles": []string, // list of strings representing example roles/titles for this angle
            "screeningQuestions": []string,
            "workstream": string 
            }
        ],
        "targetCompany": string, // client company for this project 
        "doNotContact": []string,
        "regions": []string, // geographical focus of project
        "scope": string,
        "type": string,
        "estimatedCalls": int,
        "budgetCap": float64, // in dollars
        "colleagues": [
            {
            "name": string,
            "email": string,
            "role": string or null,
            "angleName": string, // pick from one of the angles above 
            }
        ],
        "geography": string or null,
        "angle": string or null,
        "cost": float,
        "aiAnalysis": string, //write two sentences detailing your opinion on the quality of this expert
        "aiAssessment": int, //provide a score from 1 to 100 on the quality of this expert
        "availabilities": [
            {
            "start": string, // ISO 8601 format
            "end": string, // ISO 8601 format
            "callLength": int, // expected length of calls in minutes
            "geoFocus": []string, // list of strings 
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

    Here is an example of a response I want. Do not include anything beyond what the example shows. Remember to put all the relevant information within 'project':

    {
    "project": [
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

'''
#endregion

#region Interpret Information Using ChatGPT
def get_project_info(outreach_email, user_org):
    print("Getting expert information...")
    message = message_template + outreach_email

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

    project_list = json.loads(clean_data)
    for project in project_list['expert_data']:
        project['organizationID'] = user_org
        project['callsCompleted'] = '0'
        project['status'] = 'open'
        #project['targetCompany'] = target_company
        #project['DoNotContact'] = ???

    print("Expert information retrieved successfully.")
    print(project_list)
    return project_list
#endregion

#region Backend Interaction
def send_to_backend(data, token):
    print(f"Sending data to backend. Payload: {data}")
    backend_headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {token}'
    }
    response = requests.post(f'{BACKEND_URL}make-project', headers=backend_headers, data=data)
    if response.status_code == 200:
        print("Data sent to backend successfully.")
    else:
        print(f"Failed to send data to backend. Status code: {response.status_code}")
        print(f"Response: {response.text}")
#endregion

def primary_func(backend_password: str, outreach_email, user_org):
    project_list = get_project_info(outreach_email, user_org)
    if project_list == "No Project Found" or project_list is None or 'project' not in expert_list:
        print(f'value of no project: {project_list == "No Project Found"}')
        print(f'value of project list being non: {project_list is None}')
        print(f'value of comp not in list: {'project' not in project_list}')
        continue
    for project in project_list['project']:
        send_to_backend(
            data=json.dumps(project),
            token=backend_password + sender,  # Ensure these variables are correctly defined and used
            path="make-expert",
        )

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

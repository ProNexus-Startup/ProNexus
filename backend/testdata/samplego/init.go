package samplego

import (
	"github.com/rpupo63/ProNexus/backend/database/mockdb"
	"github.com/rpupo63/ProNexus/backend/models"
	"time"
)

func NewDB() mockdb.Database {
	organizations := []models.Organization{
		{ID: "org-id-1", Name: "Organization One"},
		{ID: "org-id-2", Name: "Organization Two"},
	}

	users := []models.User{
		{
			ID:             "user-id-1",
			Email:          "user1@example.com",
			FullName:       "User One",
			Password:       "hashed-password-1",
			OrganizationID: "org-id-1",
			DateOnboarded:  time.Now(),
			Admin:          false,
			SignedAt:       time.Now(),
			Token:          "token-1",
		},
		{
			ID:             "user-id-2",
			Email:          "user2@example.com",
			FullName:       "User Two",
			Password:       "hashed-password-2",
			OrganizationID: "org-id-2",
			DateOnboarded:  time.Now().Add(-24 * time.Hour),
			Admin:          false,
			SignedAt:       time.Now().Add(-24 * time.Hour),
			Token:          "token-2",
		},
	}

	availableExperts := []models.AvailableExpert{
		{
			ID:                 "expert-id-1",
			Name:               "Expert One",
			OrganizationID:     "org-id-1",
			ProjectID:          "project-id-1",
			Favorite:           true,
			Profession:              "Expert Profession One",
			Company:            "Expert Company One",
			CompanyType:        "Type One",
			StartDate:          time.Now().Add(-24 * 365 * 10 * time.Hour),
			Description:        "Description of Expert One",
			Geography:          "Location One",
			Angle:              "Angle One",
			Status:             "Available",
			AIAssessment:       85,
			Comments:           "Comments on Expert One",
			ExpertNetworkName:  "Network One",
			Cost:               200.00,
			ScreeningQuestionsAndAnswers: []models.Question{
				{Question: "What is your field of expertise?", Answer: "Field One"},
				{Question: "How many years of experience do you have?", Answer: "5 years"},
			},
			DateAddedExpert: time.Now(),
		},
	}

	callTrackers := []models.CallTracker{
		{
			ID:                "call-id-1",
			Name:              "Call Tracker One",
			ProjectID:         "project-id-1",
			OrganizationID:    "org-id-1",
			Favorite:          false,
			Profession:             "Profession One",
			Company:           "Company One",
			CompanyType:       "Type One",
			StartDate:          time.Now().Add(-10 * 365 * 20 * time.Hour),
			Description:       "Description of Call Tracker One",
			Geography:         "Location One",
			Angle:             "Angle for Call Tracker One",
			Status:            "Scheduled",
			AIAssessment:      99,
			Comments:          "Comments on Call Tracker One",
			ExpertNetworkName: "Network for Call Tracker One",
			Cost:              500.00,
			ScreeningQuestionsAndAnswers: []models.Question{
				{Question: "What topics will be discussed?", Answer: "Topic One"},
				{Question: "Any specific focus for the call?", Answer: "Focus on X"},
			},
			DateAddedExpert:   time.Now(),
			DateAddedCall:     time.Now(),
			InviteSent:        true,
			MeetingStartDate:  time.Now().Add(7 * 24 * time.Hour),
			MeetingEndDate:    time.Now().Add(8 * 24 * time.Hour),
			PaidStatus:        true,
			Rating:            4,
		},
	}

	projects := []models.Project{
		{
			ID:             "project-id-1",
			Name:           "Project One",
			OrganizationID: "org-id-1",
			StartDate:      time.Now().Add(-7 * 24 * time.Hour),
			EndDate:        time.Now().Add(7 * 24 * time.Hour),
			CallsCompleted: 5,
			Status:         "In Progress",
			Expenses: []models.Expense{
				{Name: "Expense One", Cost: 100.00, Type: "Type One"},
				{Name: "Expense Two", Cost: 200.00, Type: "Type Two"},
			},
			Angles: []models.Angle{
				{
					Name:               "Angle One",
					Description:        "Description of Angle One",
					CallLength:         30,
					GeoFocus:           []string{"Geo One", "Geo Two"},
					ExampleCompanies:   []string{"Company One", "Company Two"},
					ExampleTitles:      []string{"Title One", "Title Two"},
					ScreeningQuestions: []string{"Question One", "Question Two"},
					AIMatchPrompt:      "AI Match Prompt One",
					Workstream:         "Workstream One",
				},
			},
			TargetCompany: "Target Company One",
			DoNotContact:  []string{"Contact One", "Contact Two"},
			Regions:       []string{"Region One", "Region Two"},
			Scope:         "Scope One",
			Type:          "Type One",
			EstimatedCalls: 10,
			BudgetCap:      1000.00,
			EmailBody:    "Email body content for Project One",
			EmailSubject: "Email subject for Project One",
		},
		{
			ID:             "project-id-2",
			Name:           "Project Two",
			OrganizationID: "org-id-2",
			StartDate:      time.Now().Add(-14 * 24 * time.Hour),
			EndDate:        time.Now().Add(14 * 24 * time.Hour),
			CallsCompleted: 3,
			Status:         "Completed",
			Expenses: []models.Expense{
				{Name: "Expense Three", Cost: 300.00, Type: "Type Three"},
			},
			Angles: []models.Angle{
				{
					Name:               "Angle Two",
					Description:        "Description of Angle Two",
					CallLength:         45,
					GeoFocus:           []string{"Geo Three", "Geo Four"},
					ExampleCompanies:   []string{"Company Three", "Company Four"},
					ExampleTitles:      []string{"Title Three", "Title Four"},
					ScreeningQuestions: []string{"Question Three", "Question Four"},
					AIMatchPrompt:      "AI Match Prompt Two",
					Workstream:         "Workstream Two",
				},
			},
			TargetCompany: "Target Company Two",
			DoNotContact:  []string{"Contact Three", "Contact Four"},
			Regions:       []string{"Region Three", "Region Four"},
			Scope:         "Scope Two",
			Type:          "Type Two",
			EstimatedCalls: 5,
			BudgetCap:      2000.00,
			
			EmailBody:    "Email body content for Project Two",
			EmailSubject: "Email subject for Project Two",
		},
	}

	return mockdb.New(&organizations, &users, &availableExperts, &callTrackers, &projects)
}

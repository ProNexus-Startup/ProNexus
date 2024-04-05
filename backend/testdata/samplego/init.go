package samplego

import (
	"github.com/rpupo63/ProNexus/backend/database/mockdb"
	"github.com/rpupo63/ProNexus/backend/models"
	"time"
)

func NewDB() mockdb.Database {
	// Directly initializing slices of the correct types
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
			SignedAt:       time.Now(),
			Token:          "token-1",
		},
		{
			ID:             "user-id-2",
			Email:          "user2@example.com",
			FullName:       "User Two",
			Password:       "hashed-password-2",
			OrganizationID: "org-id-2",
			SignedAt:       time.Now().Add(-24 * time.Hour),
			Token:          "token-2",
		},
	}

	organizationIDToAvailableExpert := []models.OrganizationIDAndAvailableExpert{
		{
			OrganizationID: "org-id-1",
			AvailableExpert: []models.AvailableExpert{
				{
					ID:                "expert-id-1",
					Name:              "Expert One",
					Favorite:          true,
					Title:             "Expert Title One",
					Company:           "Expert Company One",
					YearsAtCompany:    "2",
					Description:       "Description of Expert One",
					Geography:         "Location One",
					Angle:             "Angle One",
					Status:            "Available",
					AIAssessment:      85,
					Comments:          "Comments on Expert One",
					Availability:      "Available Next Week",
					ExpertNetworkName: "Network One",
					Cost:              200.00,
					ScreeningQuestions: []string{
						"What is your field of expertise?",
						"How many years of experience do you have?",
					},
				},
			},
		},
	}

	organizationIDToCallTracker := []models.OrganizationIDAndCallTracker{
		{
			OrganizationID: "org-id-1",
			CallTracker: []models.CallTracker{
				{
					ID:                "call-id-1",
					Name:              "Call Tracker One",
					Favorite:          false,
					Title:             "Title One",
					Company:           "Company One",
					YearsAtCompany:    5,
					Description:       "Description of Call Tracker One",
					Geography:         "Location One",
					Angle:             "Angle for Call Tracker One",
					Status:            "Scheduled",
					AIAssessment:      "High",
					Comments:          "Comments on Call Tracker One",
					Availability:      "Next Month",
					ExpertNetworkName: "Network for Call Tracker One",
					Cost:              500.00,
					ScreeningQuestions: []string{
						"What topics will be discussed?",
						"Any specific focus for the call?",
					},
					InviteSent:       true,
					MeetingDate:      time.Now().Add(7 * 24 * time.Hour),
					MeetingTime:      time.Now().Add(8 * 24 * time.Hour),
					MeetingLength:    60,
					CompanyType:      "Type One",
					PaidStatus:       true,
					QuoteAttribution: "Attribution One",
					Rating:           4,
				},
			},
		},
	}

	// Initializing projects
	organizationIDToProject := []models.OrganizationIDAndProject{
		{
			OrganizationID: "org-id-1",
			Project: []models.Project{
				{
					ID:             "project-id-1",
					Name:           "Project One",
					StartDate:      time.Now().Add(-7 * 24 * time.Hour), // Example: a week ago
					Target:         "Project Target One",
					CallsCompleted: 5,
					Status:         "In Progress",
				},
			},
		},
		{
			OrganizationID: "org-id-2",
			Project: []models.Project{
				{
					ID:             "project-id-2",
					Name:           "Project Two",
					StartDate:      time.Now().Add(-14 * 24 * time.Hour), // Example: two weeks ago
					Target:         "Project Target Two",
					CallsCompleted: 3,
					Status:         "Completed",
				},
			},
		},
	}

	// Correcting the call to mockdb.New with proper types and order
	return mockdb.New(&organizations, &users, &organizationIDToAvailableExpert, &organizationIDToCallTracker, &organizationIDToProject)
}
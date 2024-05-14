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
			Title:              "Expert Title One",
			Company:            "Expert Company One",
			CompanyType:        "Type One",
			YearsAtCompany:     "2",
			Description:        "Description of Expert One",
			Geography:          "Location One",
			Angle:              "Angle One",
			Status:             "Available",
			AIAssessment:       85,
			Comments:           "Comments on Expert One",
			Availability:       "Available Next Week",
			ExpertNetworkName:  "Network One",
			Cost:               200.00,
			ScreeningQuestions: []string{"What is your field of expertise?", "How many years of experience do you have?"},
			DateAddedExpert:    time.Now(),
		},
	}

	callTrackers := []models.CallTracker{
		{
			ID:                "call-id-1",
			Name:              "Call Tracker One",
			ProjectID:         "project-id-1",
			OrganizationID:    "org-id-1",
			Favorite:          false,
			Title:             "Title One",
			Company:           "Company One",
			CompanyType:       "Type One",
			YearsAtCompany:    "Many",
			Description:       "Description of Call Tracker One",
			Geography:         "Location One",
			Angle:             "Angle for Call Tracker One",
			Status:            "Scheduled",
			AIAssessment:      99,
			Comments:          "Comments on Call Tracker One",
			Availability:      "Next Month",
			ExpertNetworkName: "Network for Call Tracker One",
			Cost:              500.00,
			ScreeningQuestions: []string{"What topics will be discussed?", "Any specific focus for the call?"},
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
			Target:         "Project Target One",
			CallsCompleted: 5,
			Status:         "In Progress",
		},
		{
			ID:             "project-id-2",
			Name:           "Project Two",
			OrganizationID: "org-id-2",
			StartDate:      time.Now().Add(-14 * 24 * time.Hour),
			Target:         "Project Target Two",
			CallsCompleted: 3,
			Status:         "Completed",
		},
	}

	return mockdb.New(&organizations, &users, &availableExperts, &callTrackers, &projects)
}

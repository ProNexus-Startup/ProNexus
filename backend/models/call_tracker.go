package models

import "time"

type OrganizationIDAndCallTracker struct {
	OrganizationID string `json:"organizationID"`
	CallTracker []CallTracker // Changed to correctly reflect the new structure of AvailableExpert
}

type CallTracker struct {
    ID           string    `json:"expertId" db:"expert_id"`
    Name               string    `json:"name" db:"name"`
    Project			   string    `json: "project" db: "project"`
    Favorite           bool      `json:"favorite" db:"favorite"`
    Title              string    `json:"title" db:"title"`
    Company            string    `json:"company" db:"company"`
    YearsAtCompany     int       `json:"yearsAtCompany" db:"years_at_company"`
    Description        string    `json:"description" db:"description"`
    Geography          string    `json:"geography" db:"geography"`
    Angle              string    `json:"angle" db:"angle"`
    Status             string    `json:"status" db:"status"` // Existing field, reused
    AIAssessment       string    `json:"AIAssessment" db:"ai_assessment"`
    Comments           string    `json:"comments" db:"comments"`
    Availability       string    `json:"availability" db:"availability"`
    ExpertNetworkName  string    `json:"expertNetworkName" db:"expert_network_name"`
    Cost               float64   `json:"cost" db:"cost"`
    ScreeningQuestions []string  `json:"screeningQuestions" db:"screening_questions"`
    InviteSent         bool      `json:"inviteSent" db:"invite_sent"`
    MeetingDate        time.Time `json:"meetingDate" db:"meeting_date"`
    MeetingTime        time.Time `json:"meetingTime" db:"meeting_time"`
    MeetingLength      int       `json:"meetingLength" db:"meeting_length"`
    CompanyType        string    `json:"companyType" db:"company_type"`
    PaidStatus         bool    `json:"paidStatus" db:"paid_status"`
    QuoteAttribution   string    `json:"quoteAttribution" db:"quote_attribution"`
    Rating             int   `json:"rating" db:"rating"`
}


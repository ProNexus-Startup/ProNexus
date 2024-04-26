package models

import "time"

type OrganizationIDAndCallTracker struct {
	OrganizationID string `json:"organizationID"`
	CallTracker []CallTracker // Changed to correctly reflect the new structure of AvailableExpert
}

type CallTracker struct {
    ID                 string    `json:"expertId" db:"expert_id"`
    Name               string    `json:"name" db:"name"`
    ProjectID		   string    `json:"projectId" db:"project_id"`
    ProjectName        string    `json:"projectName" db:"project_name"`
    Favorite           bool      `json:"favorite" db:"favorite"`
    Title              string    `json:"title" db:"title"`
    Company            string    `json:"company" db:"company"`
    CompanyType        string    `json:"companyType" db:"company_type"`
    YearsAtCompany     int       `json:"yearsAtCompany" db:"years_at_company"`
    Description        string    `json:"description" db:"description"`
    Geography          string    `json:"geography" db:"geography"`
    Angle              string    `json:"angle" db:"angle"`
    Status             string    `json:"status" db:"status"`
    AIAssessment       string    `json:"AIAssessment" db:"ai_assessment"`
    Comments           string    `json:"comments" db:"comments"`
    Availability       string    `json:"availability" db:"availability"`
    ExpertNetworkName  string    `json:"expertNetworkName" db:"expert_network_name"`
    Cost               float64   `json:"cost" db:"cost"`
    ScreeningQuestions []string  `json:"screeningQuestions" db:"screening_questions"`
    AddedExpertBy      string    `json:"addedExpertBy" db:"added_expert_by"`
    DateAddedExpert	   time.Time `json:"dateAddedExpert" db:"date_added_expert"`
    AddedCallBy        string    `json:"addedCallBy" db:"added_call_by"`
	DateAddedCall  	   time.Time `json:"dateAddedCall" db:"date_added_call"`
    InviteSent         bool      `json:"inviteSent" db:"invite_sent"`
    MeetingStartDate   time.Time `json:"meetingStartDate" db:"meeting_start_date"`
    MeetingEndDate     time.Time `json:"meetingEndDate" db:"meeting_end_date"`
    PaidStatus         bool      `json:"paidStatus" db:"paid_status"`
    Rating             int       `json:"rating" db:"rating"`
}


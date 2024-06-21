package models
import "time"

type CallTracker struct {
	ID                 string    `json:"expertId" db:"expert_id"`
	Name               string    `json:"name" db:"name"`
	OrganizationID	   string    `json:"organizationId" db:"organization_id"`
	ProjectID		   string    `json:"projectId" db:"project_id"`
	Favorite           bool      `json:"favorite" db:"favorite"`
	Profession         string    `json:"profession" db:"profession"`
	Company            string    `json:"company" db:"company"`
    CompanyType        string    `json:"companyType" db:"company_type"`
	StartDate    	   time.Time `json:"startDate" db:"start_date"`
	Description        string    `json:"description" db:"description"`
	Geography          string    `json:"geography" db:"geography"`
	Angle              string    `json:"angle" db:"angle"`
	Status             string    `json:"status" db:"status"`
	AIAssessment       int       `json:"aiAssessment" db:"ai_assessment"`
	AIAnalysis         string    `json:"aiAnalysis" db:"ai_analysis"`
	Comments           string    `json:"comments" db:"comments"`
	Availabilities     []Availability    `json:"availabilities" db:"availabilities"`
	ExpertNetworkName  string    `json:"expertNetworkName" db:"expert_network_name"`
	Cost               float64   `json:"cost" db:"cost"`
	ScreeningQuestionsAndAnswers []Question `json:"screeningQuestionsAndAnswers" db:"screening_questions_and_answers"` 
	EmploymentHistory  []Job     `json:"employmentHistory" db:"employment_history"`
	AddedExpertBy      string    `json:"addedExpertBy" db:"added_expert_by"`
	DateAddedExpert    time.Time `json:"dateAddedExpert" db:"date_added_expert"`
	Trends             string    `json:"trends" db:"trends"`
    AddedCallBy        string    `json:"addedCallBy" db:"added_call_by"`
    DateAddedCall      time.Time `json:"dateAddedCall" db:"date_added_call"`
    InviteSent         bool      `json:"inviteSent" db:"invite_sent"`
    MeetingStartDate   time.Time `json:"meetingStartDate" db:"meeting_start_date"`
    MeetingEndDate     time.Time `json:"meetingEndDate" db:"meeting_end_date"`
    PaidStatus         bool      `json:"paidStatus" db:"paid_status"`
    Rating             int      `json:"rating" db:"rating"`
	LinkedInLink       string               `json:"linkedInLink" db:"linkedIn_link"`
}
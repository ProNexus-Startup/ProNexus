package models

type OrganizationIDAndAvailableExpert struct {
	OrganizationID string `json:"organizationID"`
	AvailableExpert []AvailableExpert
}

type AvailableExpert struct {
	ID                 string    `json:"expertId" db:"expert_id"`
	Name               string    `json:"name" db:"name"`
	ProjectId		   string    `json: "projectId" db: "project_id"`
	Favorite           bool      `json:"favorite" db:"favorite"`
	Title              string    `json:"title" db:"title"`
	Company            string    `json:"company" db:"company"`
	YearsAtCompany     string    `json:"yearsAtCompany" db:"years_at_company"`
	Description        string    `json:"description" db:"description"`
	Geography          string    `json:"geography" db:"geography"`
	Angle              string    `json:"angle" db:"angle"`
	Status             string    `json:"status" db:"status"`
	AIAssessment       int       `json:"AIAssessment" db:"ai_assessment"`
	Comments           string    `json:"comments" db:"comments"`
	Availability       string    `json:"availability" db:"availability"`
	ExpertNetworkName  string    `json:"expertNetworkName" db:"expert_network_name"`
	Cost               float64   `json:"cost" db:"cost"`
	ScreeningQuestions []string `json:"screeningQuestions" db:"screening_questions"`
}

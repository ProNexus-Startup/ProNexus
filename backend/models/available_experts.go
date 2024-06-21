package models
import (
	"time"
	"encoding/json"
)

type AvailableExpert struct {
	ID                 string  			    `json:"expertId" db:"expert_id"`
	Name               string 			    `json:"name" db:"name"`
	OrganizationID	   string  			    `json:"organizationId" db:"organization_id"`
	ProjectID		   string  			    `json:"projectId" db:"project_id"`
	Favorite           bool   			    `json:"favorite" db:"favorite"`
	Profession         string  			    `json:"profession" db:"profession"`
	Company            string  			    `json:"company" db:"company"`
    CompanyType        string    			`json:"companyType" db:"company_type"`
	StartDate     	   time.Time 			`json:"startDate" db:"start_date"`
	Description        string 			    `json:"description" db:"description"`
	Geography          string  				`json:"geography" db:"geography"`
	Angle              string   			`json:"angle" db:"angle"`
	Status             string 			    `json:"status" db:"status"`
	AIAssessment       int     		        `json:"aiAssessment" db:"ai_assessment"`
	AIAnalysis         string    			`json:"aiAnalysis" db:"ai_analysis"`
	Comments           string    			`json:"comments" db:"comments"`
	Availabilities     []Availability       `json:"availabilities" db:"availabilities"`
	ExpertNetworkName  string               `json:"expertNetworkName" db:"expert_network_name"`
	Cost               float64              `json:"cost" db:"cost"`
	ScreeningQuestionsAndAnswers []Question `json:"screeningQuestionsAndAnswers" db:"screening_questions_and_answers"` 
	EmploymentHistory  []Job                `json:"employmentHistory" db:"employment_history"`
	AddedExpertBy      string               `json:"addedExpertBy" db:"added_expert_by"`
	DateAddedExpert    time.Time		    `json:"dateAddedExpert" db:"date_added_expert"`
	Trends             string   		    `json:"trends" db:"trends"`
	LinkedInLink       string               `json:"linkedInLink" db:"linkedIn_link"`
}

type Question struct {
    Question string `json:"question"`
    Answer   string `json:"answer"`
}

type Job struct {
	Role	  string 
	Company   string
	StartDate string
	EndDate   string
}

type Availability struct {
    Start    time.Time     `json:"start" db:"start"`
    End      time.Time     `json"end" db:"end"`
    TimeZone *time.Location `json"timeZone" db:"time_zone"`
}


func (a *Availability) UnmarshalJSON(data []byte) error {
	type Alias Availability
	aux := &struct {
		TimeZone string `json:"timeZone"`
		*Alias
	}{
		Alias: (*Alias)(a),
	}

	if err := json.Unmarshal(data, &aux); err != nil {
		return err
	}

	location, err := time.LoadLocation(aux.TimeZone)
	if err != nil {
		return err
	}
	a.TimeZone = location

	return nil
}

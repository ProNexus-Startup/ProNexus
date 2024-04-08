package models
import "time"

type OrganizationIDAndProject struct {
	OrganizationID string `json:"organizationID"`
	Project        []Project
}

type Project struct {
    ID             string    `json:"projectId" db:"project_id"`
    Name           string    `json:"name" db:"name"`
    StartDate      time.Time `json:"startDate" db:"start_date"`
    Target         string    `json:"target" db:"target"`
    CallsCompleted int       `json:"callsCompleted" db:"calls_completed"`
    Status         string    `json:"status" db:"status"`
}

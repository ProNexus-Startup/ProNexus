package models
import "time"

type Project struct {
    ID             string    `json:"projectId" db:"project_id"`
    Name           string    `json:"name" db:"name"`
    OrganizationID string 	 `json:"organizationId" db:"organization_id"`
    StartDate      time.Time `json:"startDate" db:"start_date"`
    EndDate        time.Time `json:"endDate" db:"end_date"`
    Target         string    `json:"target" db:"target"`
    CallsCompleted int       `json:"callsCompleted" db:"calls_completed"`
    Status         string    `json:"status" db:"status"`
}

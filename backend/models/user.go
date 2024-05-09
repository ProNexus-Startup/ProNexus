package models

import "time"

type User struct {
    ID             string    `json:"id" db:"id"`
    Email          string    `json:"email" db:"email"`
    FullName       string    `json:"fullName" db:"full_name"`
    Password       string    `json:"password" db:"password"`
    OrganizationID string    `json:"organizationId" db:"organization_id"`
    ProjectID      string    `json:"projectId" db:"project_id"`
    DateOnboarded  time.Time `json:"dateOnboarded" db:"date_onboarded"`
    PastProjectIDs []string  `json:"pastProjectIDs" db:"past_project_ids"`
    Admin          bool      `json:"admin" db:"admin"`
    SignedAt       time.Time `json:"signedAt" db:"signed_at"`
    Token          string    `json:"token" db:"token"`
}

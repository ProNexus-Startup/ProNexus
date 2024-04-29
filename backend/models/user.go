package models

import "time"

type OrganizationIDAndUser struct {
    OrganizationID string `json:"organizationID"`
    User           []User `json:"user"` // Ensure to include JSON tags if you plan to serialize to JSON
}

type User struct {
    ID             string    `json:"id" db:"id"`
    Email          string    `json:"email" db:"email"`
    FullName       string    `json:"fullName" db:"full_name"`
    Password       string    `json:"password" db:"password"`
    OrganizationID string    `json:"organizationId" db:"organization_id"`
    ProjectID      string    `json:"projectId" db:"project_id"`
    DateOnboarded  time.Time `json:"dateOnboarded" db:"date_onboarded"`
    PastProjectIDs []string  `json:"pastProjectIDs" db:"past_project_ids"`
    SignedAt       time.Time `json:"signedAt" db:"signed_at"`
    Token          string    `json:"token" db:"token"`
}

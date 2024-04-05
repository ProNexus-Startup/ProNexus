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
    OrganizationID string    `json:"organizationID" db:"organization_id"` // Corrected
    SignedAt       time.Time `json:"signedAt" db:"signed_at"`
    Token          string    `json:"token" db:"token"`
}

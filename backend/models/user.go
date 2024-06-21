package models

import "time"

type User struct {
    ID             string    `json:"id" db:"id"`
    Email          string    `json:"email" db:"email"`
    FullName       string    `json:"fullName" db:"full_name"`
    Password       string    `json:"password" db:"password"`
    OrganizationID string    `json:"organizationId" db:"organization_id"`
    DateOnboarded  time.Time `json:"dateOnboarded" db:"date_onboarded"`
    CurrentProject string    `json:"currentProject" db:"currentProject"`
    PastProjects   []Proj    `json:"pastProjectIDs" db:"past_projects"`
    Admin          bool      `json:"admin" db:"admin"`
    Level          string    `json:"level" db:"level"`
    SignedAt       time.Time `json:"signedAt" db:"signed_at"`
    Token          string    `json:"token" db:"token"`
}

type Proj struct {
    Start     time.Time `json:"start" db:"start"`
    End       time.Time `json:"end" db:"end"`
    ProjectID string    `json:"projectId" db:"projectId"`
}

package models

import "time"

type Project struct {
    ID             string       `json:"projectId" db:"project_id"`
    Name           string       `json:"name" db:"name"`
    OrganizationID string       `json:"organizationId" db:"organization_id"`
    StartDate      time.Time    `json:"startDate" db:"start_date"`
    EndDate        time.Time   `json:"endDate" db:"end_date"` // Pointer to handle null values
    CallsCompleted int          `json:"callsCompleted" db:"calls_completed"`
    Status         string       `json:"status" db:"status"`
    Expenses       []Expense    `json:"expenses" db:"expenses"` // Default to empty slice instead of null
    Angles         []Angle      `json:"angles" db:"angles"`     // Default to empty slice instead of null
    TargetCompany  string       `json:"targetCompany" db:"target_company"`
    DoNotContact   []string     `json:"doNotContact" db:"do_not_contact"`
    Regions        []string     `json:"regions" db:"regions"`
    Scope          string       `json:"scope" db:"scope"`
    Type           string       `json:"type" db:"type"`
    EstimatedCalls int          `json:"estimatedCalls" db:"estimated_calls"`
    BudgetCap      float64      `json:"budgetCap" db:"budget_cap"`
    EmailBody      string       `json:"emailBody" db:"email_body"`
    EmailSubject   string       `json:"emailSubject" db:"email_subject"`
    Colleagues     []Colleague  `json:"colleagues" db:"colleagues"` // Default to empty slice instead of null
}

type Expense struct {
    Name string  `json:"name" db:"name"`
    Cost float64 `json:"cost" db:"cost"`
    Type string  `json:"type" db:"type"`
}

type Angle struct {
    ID                 string   `json:"id" db:"id"`
    Name               string   `json:"name" db:"name"`
    Description        string   `json:"description" db:"description"`
    CallLength         int      `json:"callLength" db:"call_length"`
    GeoFocus           []string `json:"geoFocus" db:"geo_focus"`
    ExampleCompanies   []string `json:"exampleCompanies" db:"example_companies"`
    ExampleTitles      []string `json:"exampleTitles" db:"example_titles"`
    ScreeningQuestions []string `json:"screeningQuestions" db:"screening_questions"`
    AIMatchPrompt      string   `json:"aiMatchPrompt" db:"AI_match_prompt"`
    Workstream         string   `json:"workstream" db:"workstream"`
}

type Colleague struct {
    Name          string `json:"name" db:"name"`
    Email         string `json:"email" db:"email"`
    Role          string `json:"role" db:"role"`
    AngleName     string `json:"angleName" db:"angle_name"`
    CalendarLinked bool `json:"calendarLinked" db:"calendar_linked"`
}

/*
type Workstream struct {
    Name       string `json:"name" db:"name"`
    Colleagues []Colleague `json:"networksUsed" db:"networks_used"`
}
*/
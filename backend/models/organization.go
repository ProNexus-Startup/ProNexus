package models

type Organization struct {
	ID    string `json:"id"    db:"id"`
	Name  string `json:"name"  db:"name"`
	Token string `json:"token" db:"token"`
}
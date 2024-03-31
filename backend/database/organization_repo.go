package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type OrganizationRepo interface {
	SelectAll() ([]models.Organization, error) // List all organizations
	FindByID(id string) (models.Organization, error) // Find a single organization by ID
	FindByName(name string) (models.Organization, error)
	Insert(organization models.Organization) error // Insert a new organization
	Update(organization models.Organization) error // Update an existing organization
	// Consider adding a Delete method if needed
}

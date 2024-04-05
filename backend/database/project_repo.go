package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type ProjectRepo interface {
    SelectByOrganizationID(organizationID string) ([]models.Project, error)
    Insert(organizationID string, entry models.Project) error
    Delete(organizationID string, projectID string) error
}

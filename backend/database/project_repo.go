package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type ProjectRepo interface {
    FindByOrganization(organizationID string) ([]models.Project, error)
    Insert(entry models.Project) error
    Delete(projectID string) error
    Update(projectFields models.Project) error
    FindByID(id string) (models.Project, error)
}

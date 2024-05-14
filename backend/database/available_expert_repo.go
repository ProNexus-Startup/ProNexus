package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type AvailableExpertRepo interface {
    FindByOrganization(organizationID string) ([]models.AvailableExpert, error)
    FindByProject(projectID string, organizationID string) ([]models.AvailableExpert, error)
    Insert(entry models.AvailableExpert) error
    Delete(availableExpertID string) error
    Update(updatedTracker models.AvailableExpert) error

}

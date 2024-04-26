package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type AvailableExpertRepo interface {
    SelectByOrganizationID(organizationID string) ([]models.AvailableExpert, error)
    SelectByProject(projectID string, organizationID string) ([]models.AvailableExpert, error)
    Insert(organizationID string, entry models.AvailableExpert) error
    Delete(organizationID string, availableExpertID string) error
    Update(organizationID string, updatedTracker models.AvailableExpert) error

}

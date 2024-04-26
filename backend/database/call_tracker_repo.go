package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type CallTrackerRepo interface {
    SelectByOrganizationID(organizationID string) ([]models.CallTracker, error)
    Insert(organizationID string, entry models.CallTracker) error
    Delete(organizationID string, callTrackerID string) error
    Update(organizationID string, updatedTracker models.CallTracker) error
}

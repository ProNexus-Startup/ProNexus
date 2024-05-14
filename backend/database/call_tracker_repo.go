package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type CallTrackerRepo interface {
    FindByOrganization(organizationID string) ([]models.CallTracker, error)
    Insert(entry models.CallTracker) error
    Delete(callTrackerID string) error
    Update(updatedTracker models.CallTracker) error
}

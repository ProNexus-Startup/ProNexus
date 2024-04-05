package mockdb

import (
    "github.com/rpupo63/ProNexus/backend/models"
    "errors"
    "github.com/google/uuid"
)

type CallTrackerRepo struct {
    organizationIDToCallTracker *[]models.OrganizationIDAndCallTracker
}

func NewCallTrackerRepo(organizationIDToCallTracker *[]models.OrganizationIDAndCallTracker) *CallTrackerRepo {
    return &CallTrackerRepo{organizationIDToCallTracker}
}

func (r *CallTrackerRepo) SelectByOrganizationID(organizationID string) ([]models.CallTracker, error) {
    for _, entry := range *r.organizationIDToCallTracker {
        if entry.OrganizationID == organizationID {
            return entry.CallTracker, nil
        }
    }
    return []models.CallTracker{}, nil
}

func (r *CallTrackerRepo) Insert(organizationID string, callTracker models.CallTracker) error {
    // Generate a new UUID if the callTracker does not have an ID yet.
    if callTracker.ID == "" {
        newUUID, err := uuid.NewUUID()
        if err != nil {
            return err // Return an error if failed to generate UUID
        }
        callTracker.ID = newUUID.String()
    }

    found := false
    for i, entry := range *r.organizationIDToCallTracker {
        if entry.OrganizationID == organizationID {
            (*r.organizationIDToCallTracker)[i].CallTracker = append(entry.CallTracker, callTracker)
            found = true
            break
        }
    }

    if !found {
        newOrganizationEntry := models.OrganizationIDAndCallTracker{
            OrganizationID: organizationID,
            CallTracker:    []models.CallTracker{callTracker},
        }
        *r.organizationIDToCallTracker = append(*r.organizationIDToCallTracker, newOrganizationEntry)
    }

    return nil
}


func (r *CallTrackerRepo) Delete(organizationID string, callTrackerID string) error {
    for i, entry := range *r.organizationIDToCallTracker {
        if entry.OrganizationID == organizationID {
            for j, tracker := range entry.CallTracker {
                if tracker.ID == callTrackerID { // Correct reference to callTrackerID parameter
                    // Remove the call tracker by slicing it out
                    (*r.organizationIDToCallTracker)[i].CallTracker = append(entry.CallTracker[:j], entry.CallTracker[j+1:]...)
                    return nil
                }
            }
            return errors.New("call tracker not found")
        }
    }
    return errors.New("organization not found")
}
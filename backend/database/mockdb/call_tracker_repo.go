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

func (r *CallTrackerRepo) Update(organizationID string, updatedTracker models.CallTracker) error {
    for i, entry := range *r.organizationIDToCallTracker {
        if entry.OrganizationID == organizationID {
            for j, tracker := range entry.CallTracker {
                if tracker.ID == updatedTracker.ID {
                    // Update the call tracker fields with the fields from updatedTracker
                    tracker.Name = updatedTracker.Name
                    tracker.ProjectID = updatedTracker.ProjectID
                    tracker.Favorite = updatedTracker.Favorite
                    tracker.Title = updatedTracker.Title
                    tracker.Company = updatedTracker.Company
                    tracker.CompanyType = updatedTracker.CompanyType
                    tracker.YearsAtCompany = updatedTracker.YearsAtCompany
                    tracker.Description = updatedTracker.Description
                    tracker.Geography = updatedTracker.Geography
                    tracker.Angle = updatedTracker.Angle
                    tracker.Status = updatedTracker.Status
                    tracker.AIAssessment = updatedTracker.AIAssessment
                    tracker.Comments = updatedTracker.Comments
                    tracker.Availability = updatedTracker.Availability
                    tracker.ExpertNetworkName = updatedTracker.ExpertNetworkName
                    tracker.Cost = updatedTracker.Cost
                    tracker.ScreeningQuestions = updatedTracker.ScreeningQuestions
                    tracker.DateAddedExpert = updatedTracker.DateAddedExpert
                    tracker.DateAddedCall = updatedTracker.DateAddedCall
                    tracker.InviteSent = updatedTracker.InviteSent
                    tracker.MeetingStartDate = updatedTracker.MeetingStartDate
                    tracker.MeetingEndDate = updatedTracker.MeetingEndDate
                    tracker.PaidStatus = updatedTracker.PaidStatus
                    tracker.Rating = updatedTracker.Rating

                    // Assign the updated tracker back to the slice
                    (*r.organizationIDToCallTracker)[i].CallTracker[j] = tracker
                    return nil
                }
            }
            return errors.New("call tracker not found")
        }
    }
    return errors.New("organization not found")
}

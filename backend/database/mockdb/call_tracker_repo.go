package mockdb

import (
    "errors"
    "github.com/google/uuid"
    "github.com/rpupo63/ProNexus/backend/models"
)

type CallTrackerRepo struct {
    calls *[]models.CallTracker
}

func NewCallTrackerRepo(calls *[]models.CallTracker) *CallTrackerRepo {
    return &CallTrackerRepo{calls}
}

func (r *CallTrackerRepo) FindByOrganization(organizationID string) ([]models.CallTracker, error) {
    var results []models.CallTracker
    for _, call := range *r.calls {
        if call.OrganizationID == organizationID {
            results = append(results, call)
        }
    }
    return results, nil
}

func (r *CallTrackerRepo) SelectByProject(projectID string, organizationID string) ([]models.CallTracker, error) {
    var results []models.CallTracker
    for _, call := range *r.calls {
        if call.OrganizationID == organizationID && call.ProjectID == projectID {
            results = append(results, call)
        }
    }
    return results, nil
}

func (r *CallTrackerRepo) Insert(call models.CallTracker) error {
    if call.ID == "" {
        newUUID, err := uuid.NewUUID()
        if err != nil {
            return err
        }
        call.ID = newUUID.String()
    }
    *r.calls = append(*r.calls, call)
    return nil
}

func (r *CallTrackerRepo) Delete(callID string) error {
    calls := *r.calls
    for i, call := range calls {
        if call.ID == callID {
            *r.calls = append(calls[:i], calls[i+1:]...)
            return nil
        }
    }
    return errors.New("call not found")
}

func (r *CallTrackerRepo) Update(updatedCall models.CallTracker) error {
    calls := *r.calls
    for i, call := range calls {
        if call.ID == updatedCall.ID {
            // Update fields if they are not zero-values (default values)
            if updatedCall.Name != "" {
                calls[i].Name = updatedCall.Name
            }
            if updatedCall.OrganizationID != "" {
                calls[i].OrganizationID = updatedCall.OrganizationID
            }
            if updatedCall.ProjectID != "" {
                calls[i].ProjectID = updatedCall.ProjectID
            }
            if updatedCall.Title != "" {
                calls[i].Title = updatedCall.Title
            }
            if updatedCall.Company != "" {
                calls[i].Company = updatedCall.Company
            }
            if updatedCall.CompanyType != "" {
                calls[i].CompanyType = updatedCall.CompanyType
            }
            if updatedCall.YearsAtCompany != "" {
                calls[i].YearsAtCompany = updatedCall.YearsAtCompany
            }
            if updatedCall.Description != "" {
                calls[i].Description = updatedCall.Description
            }
            if updatedCall.Geography != "" {
                calls[i].Geography = updatedCall.Geography
            }
            if updatedCall.Angle != "" {
                calls[i].Angle = updatedCall.Angle
            }
            if updatedCall.Status != "" {
                calls[i].Status = updatedCall.Status
            }
            if updatedCall.AIAssessment != 0 {
                calls[i].AIAssessment = updatedCall.AIAssessment
            }
            if updatedCall.Comments != "" {
                calls[i].Comments = updatedCall.Comments
            }
            if updatedCall.Availability != "" {
                calls[i].Availability = updatedCall.Availability
            }
            if updatedCall.ExpertNetworkName != "" {
                calls[i].ExpertNetworkName = updatedCall.ExpertNetworkName
            }
            if updatedCall.Cost != 0 {
                calls[i].Cost = updatedCall.Cost
            }
            if updatedCall.ScreeningQuestions != nil {
                calls[i].ScreeningQuestions = updatedCall.ScreeningQuestions
            }
            if updatedCall.AddedExpertBy != "" {
                calls[i].AddedExpertBy = updatedCall.AddedExpertBy
            }
            if !updatedCall.DateAddedExpert.IsZero() {
                calls[i].DateAddedExpert = updatedCall.DateAddedExpert
            }
            if updatedCall.AddedCallBy != "" {
                calls[i].AddedCallBy = updatedCall.AddedCallBy
            }
            if !updatedCall.DateAddedCall.IsZero() {
                calls[i].DateAddedCall = updatedCall.DateAddedCall
            }
            calls[i].InviteSent = updatedCall.InviteSent // always update because it's a boolean
            if !updatedCall.MeetingStartDate.IsZero() {
                calls[i].MeetingStartDate = updatedCall.MeetingStartDate
            }
            if !updatedCall.MeetingEndDate.IsZero() {
                calls[i].MeetingEndDate = updatedCall.MeetingEndDate
            }
            calls[i].PaidStatus = updatedCall.PaidStatus // always update because it's a boolean
            if updatedCall.Rating != 0 {
                calls[i].Rating = updatedCall.Rating
            }
            calls[i].Favorite = updatedCall.Favorite // always update because it's a boolean

            // Replace the record in the slice
            (*r.calls)[i] = calls[i]
            return nil
        }
    }
    return errors.New("call not found")
}


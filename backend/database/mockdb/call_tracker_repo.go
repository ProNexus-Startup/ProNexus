package mockdb

import (
    "errors"
    "github.com/google/uuid"
    "github.com/rpupo63/ProNexus/backend/models"
    "time"
    "reflect"
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
    for i, call := range *r.calls {
        if call.ID == updatedCall.ID {
            updateField := func(newVal, oldVal interface{}) interface{} {
                if newVal != oldVal && newVal != reflect.Zero(reflect.TypeOf(newVal)).Interface() {
                    return newVal
                }
                return oldVal
            }

            calls := *r.calls

            calls[i].Name = updateField(updatedCall.Name, calls[i].Name).(string)
            calls[i].OrganizationID = updateField(updatedCall.OrganizationID, calls[i].OrganizationID).(string)
            calls[i].ProjectID = updateField(updatedCall.ProjectID, calls[i].ProjectID).(string)
            calls[i].Profession = updateField(updatedCall.Profession, calls[i].Profession).(string)
            calls[i].Company = updateField(updatedCall.Company, calls[i].Company).(string)
            calls[i].CompanyType = updateField(updatedCall.CompanyType, calls[i].CompanyType).(string)
            calls[i].StartDate = updateField(updatedCall.StartDate, calls[i].StartDate).(time.Time)
            calls[i].Description = updateField(updatedCall.Description, calls[i].Description).(string)
            calls[i].Geography = updateField(updatedCall.Geography, calls[i].Geography).(string)
            calls[i].Angle = updateField(updatedCall.Angle, calls[i].Angle).(string)
            calls[i].Status = updateField(updatedCall.Status, calls[i].Status).(string)
            calls[i].AIAssessment = updateField(updatedCall.AIAssessment, calls[i].AIAssessment).(int)
            calls[i].AIAnalysis = updateField(updatedCall.AIAnalysis, calls[i].AIAnalysis).(string)
            calls[i].Comments = updateField(updatedCall.Comments, calls[i].Comments).(string)
            calls[i].Availabilities = updateField(updatedCall.Availabilities, calls[i].Availabilities).([]models.Availability)
            calls[i].ExpertNetworkName = updateField(updatedCall.ExpertNetworkName, calls[i].ExpertNetworkName).(string)
            calls[i].Cost = updateField(updatedCall.Cost, calls[i].Cost).(float64)
            calls[i].ScreeningQuestionsAndAnswers = updateField(updatedCall.ScreeningQuestionsAndAnswers, calls[i].ScreeningQuestionsAndAnswers).([]models.Question)
            calls[i].AddedExpertBy = updateField(updatedCall.AddedExpertBy, calls[i].AddedExpertBy).(string)
            calls[i].DateAddedExpert = updateField(updatedCall.DateAddedExpert, calls[i].DateAddedExpert).(time.Time)
            calls[i].AddedCallBy = updateField(updatedCall.AddedCallBy, calls[i].AddedCallBy).(string)
            calls[i].DateAddedCall = updateField(updatedCall.DateAddedCall, calls[i].DateAddedCall).(time.Time)
            calls[i].InviteSent = updatedCall.InviteSent // always update because it's a boolean
            calls[i].MeetingStartDate = updateField(updatedCall.MeetingStartDate, calls[i].MeetingStartDate).(time.Time)
            calls[i].MeetingEndDate = updateField(updatedCall.MeetingEndDate, calls[i].MeetingEndDate).(time.Time)
            calls[i].PaidStatus = updatedCall.PaidStatus // always update because it's a boolean
            calls[i].Rating = updateField(updatedCall.Rating, calls[i].Rating).(int)
            calls[i].Favorite = updatedCall.Favorite // always update because it's a boolean

            return nil
        }
    }
    return errors.New("call not found")
}

package mockdb

import (
    "errors"
    "github.com/google/uuid"
    "github.com/rpupo63/ProNexus/backend/models"
    "time"
    "reflect"
)

type AvailableExpertRepo struct {
    experts *[]models.AvailableExpert
}

func NewAvailableExpertRepo(experts *[]models.AvailableExpert) *AvailableExpertRepo {
    return &AvailableExpertRepo{experts}
}

func (r *AvailableExpertRepo) FindByOrganization(organizationID string) ([]models.AvailableExpert, error) {
    var results []models.AvailableExpert
    for _, expert := range *r.experts {
        if expert.OrganizationID == organizationID {
            results = append(results, expert)
        }
    }
    return results, nil
}

func (r *AvailableExpertRepo) FindByProject(projectID string, organizationID string) ([]models.AvailableExpert, error) {
    var results []models.AvailableExpert
    for _, expert := range *r.experts {
        if expert.OrganizationID == organizationID && expert.ProjectID == projectID {
            results = append(results, expert)
        }
    }
    return results, nil
}

func (r *AvailableExpertRepo) Insert(expert models.AvailableExpert) error {
    if expert.ID == "" {
        newUUID, err := uuid.NewUUID()
        if err != nil {
            return err
        }
        expert.ID = newUUID.String()
    }
    *r.experts = append(*r.experts, expert)
    return nil
}

func (r *AvailableExpertRepo) FindByID(id string) (models.AvailableExpert, error) {
	for _, expert := range *r.experts {
		if id == expert.ID {
			return expert, nil
		}
	}
	return models.AvailableExpert{}, errors.New("expert not found")
}

func (r *AvailableExpertRepo) Delete(expertID string) error {
    experts := *r.experts
    for i, expert := range experts {
        if expert.ID == expertID {
            *r.experts = append(experts[:i], experts[i+1:]...)
            return nil
        }
    }
    return errors.New("expert not found")
}
func (r *AvailableExpertRepo) Update(updatedExpert models.AvailableExpert) error {
    for i, expert := range *r.experts {
        if expert.ID == updatedExpert.ID {
            updateField := func(newVal, oldVal interface{}) interface{} {
                if newVal != oldVal && newVal != reflect.Zero(reflect.TypeOf(newVal)).Interface() {
                    return newVal
                }
                return oldVal
            }

            experts := *r.experts
            experts[i].Name = updateField(updatedExpert.Name, experts[i].Name).(string)
            experts[i].OrganizationID = updateField(updatedExpert.OrganizationID, experts[i].OrganizationID).(string)
            experts[i].ProjectID = updateField(updatedExpert.ProjectID, experts[i].ProjectID).(string)
            experts[i].Profession = updateField(updatedExpert.Profession, experts[i].Profession).(string)
            experts[i].Company = updateField(updatedExpert.Company, experts[i].Company).(string)
            experts[i].CompanyType = updateField(updatedExpert.CompanyType, experts[i].CompanyType).(string)
            experts[i].StartDate = updateField(updatedExpert.StartDate, experts[i].StartDate).(time.Time)
            experts[i].Description = updateField(updatedExpert.Description, experts[i].Description).(string)
            experts[i].Geography = updateField(updatedExpert.Geography, experts[i].Geography).(string)
            experts[i].Angle = updateField(updatedExpert.Angle, experts[i].Angle).(string)
            experts[i].Status = updateField(updatedExpert.Status, experts[i].Status).(string)
            experts[i].AIAssessment = updateField(updatedExpert.AIAssessment, experts[i].AIAssessment).(int)
            experts[i].AIAnalysis = updateField(updatedExpert.AIAnalysis, experts[i].AIAnalysis).(string)
            experts[i].Comments = updateField(updatedExpert.Comments, experts[i].Comments).(string)
            experts[i].Availabilities = updateField(updatedExpert.Availabilities, experts[i].Availabilities).([]models.Availability)
            experts[i].ExpertNetworkName = updateField(updatedExpert.ExpertNetworkName, experts[i].ExpertNetworkName).(string)
            experts[i].Cost = updateField(updatedExpert.Cost, experts[i].Cost).(float64)
            experts[i].ScreeningQuestionsAndAnswers = updateField(updatedExpert.ScreeningQuestionsAndAnswers, experts[i].ScreeningQuestionsAndAnswers).([]models.Question)
            experts[i].AddedExpertBy = updateField(updatedExpert.AddedExpertBy, experts[i].AddedExpertBy).(string)
            experts[i].DateAddedExpert = updateField(updatedExpert.DateAddedExpert, experts[i].DateAddedExpert).(time.Time)
            experts[i].Favorite = updatedExpert.Favorite // always update because it's a boolean
            experts[i].LinkedInLink = updateField(updatedExpert.LinkedInLink, experts[i].LinkedInLink).(string)

            // Replace the record in the slice
            (*r.experts)[i] = experts[i]
            return nil
        }
    }
    return errors.New("expert not found")
}

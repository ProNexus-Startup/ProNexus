package mockdb

import (
    "github.com/rpupo63/ProNexus/backend/models"
    "errors"
    "github.com/google/uuid"
)

type AvailableExpertRepo struct {
    organizationIDToAvailableExpert *[]models.OrganizationIDAndAvailableExpert
}

func NewAvailableExpertRepo(organizationIDToAvailableExpert *[]models.OrganizationIDAndAvailableExpert) *AvailableExpertRepo {
    return &AvailableExpertRepo{organizationIDToAvailableExpert}
}

func (r *AvailableExpertRepo) SelectByOrganizationID(organizationID string) ([]models.AvailableExpert, error) {
    for _, entry := range *r.organizationIDToAvailableExpert {
        if entry.OrganizationID == organizationID {
            return entry.AvailableExpert, nil
        }
    }
    return []models.AvailableExpert{}, nil
}

func (r *AvailableExpertRepo) SelectByProject(projectID string, organizationID string) ([]models.AvailableExpert, error) {
    var filteredExperts []models.AvailableExpert
    for _, entry := range *r.organizationIDToAvailableExpert {
        if entry.OrganizationID == organizationID {
            for _, expert := range entry.AvailableExpert {
                if expert.ProjectID == projectID {
                    filteredExperts = append(filteredExperts, expert)
                }
            }
            break
        }
    }
    if len(filteredExperts) > 0 {
        return filteredExperts, nil
    }
    return []models.AvailableExpert{}, nil
}


func (r *AvailableExpertRepo) Insert(organizationID string, availableExpert models.AvailableExpert) error {
    if availableExpert.ID == "" {
        newUUID, err := uuid.NewUUID()
        if err != nil {
            return err // Return an error if failed to generate UUID
        }
        availableExpert.ID = newUUID.String()
    }
    
    found := false
    for i, entry := range *r.organizationIDToAvailableExpert {
        if entry.OrganizationID == organizationID {
            (*r.organizationIDToAvailableExpert)[i].AvailableExpert = append(entry.AvailableExpert, availableExpert)
            found = true
            break
        }
    }
    if !found {
        newOrganizationEntry := models.OrganizationIDAndAvailableExpert{
            OrganizationID: organizationID,
            AvailableExpert: []models.AvailableExpert{availableExpert},
        }
        *r.organizationIDToAvailableExpert = append(*r.organizationIDToAvailableExpert, newOrganizationEntry)
    }
    return nil
}

func (r *AvailableExpertRepo) Delete(organizationID string, availableExpertID string) error {
    for i, entry := range *r.organizationIDToAvailableExpert {
        if entry.OrganizationID == organizationID {
            for j, tracker := range entry.AvailableExpert {
                if tracker.ID == availableExpertID {
                    (*r.organizationIDToAvailableExpert)[i].AvailableExpert = append(entry.AvailableExpert[:j], entry.AvailableExpert[j+1:]...)
                    return nil
                }
            }
            return errors.New("expert tracker not found")
        }
    }
    return errors.New("organization not found")
}


func (r *AvailableExpertRepo) Update(organizationID string, updatedTracker models.AvailableExpert) error {
    for i, entry := range *r.organizationIDToAvailableExpert {
        if entry.OrganizationID == organizationID {
            for j, tracker := range entry.AvailableExpert {
                if tracker.ID == updatedTracker.ID {
                    tracker.Name = updatedTracker.Name
                    tracker.ProjectID = updatedTracker.ProjectID
                    tracker.ProjectName = updatedTracker.ProjectName
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

                    (*r.organizationIDToAvailableExpert)[i].AvailableExpert[j] = tracker
                    return nil
                }
            }
            return errors.New("expert not found")
        }
    }
    return errors.New("organization not found")
}

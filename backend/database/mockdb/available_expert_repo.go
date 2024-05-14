package mockdb

import (
    "errors"
    "github.com/google/uuid"
    "github.com/rpupo63/ProNexus/backend/models"
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
    experts := *r.experts
    for i, expert := range experts {
        if expert.ID == updatedExpert.ID {
            // Update fields if they are not zero-values (default values)
            if updatedExpert.Name != "" {
                experts[i].Name = updatedExpert.Name
            }
            if updatedExpert.OrganizationID != "" {
                experts[i].OrganizationID = updatedExpert.OrganizationID
            }
            if updatedExpert.ProjectID != "" {
                experts[i].ProjectID = updatedExpert.ProjectID
            }
            if updatedExpert.Title != "" {
                experts[i].Title = updatedExpert.Title
            }
            if updatedExpert.Company != "" {
                experts[i].Company = updatedExpert.Company
            }
            if updatedExpert.CompanyType != "" {
                experts[i].CompanyType = updatedExpert.CompanyType
            }
            if updatedExpert.YearsAtCompany != "" {
                experts[i].YearsAtCompany = updatedExpert.YearsAtCompany
            }
            if updatedExpert.Description != "" {
                experts[i].Description = updatedExpert.Description
            }
            if updatedExpert.Geography != "" {
                experts[i].Geography = updatedExpert.Geography
            }
            if updatedExpert.Angle != "" {
                experts[i].Angle = updatedExpert.Angle
            }
            if updatedExpert.Status != "" {
                experts[i].Status = updatedExpert.Status
            }
            if updatedExpert.AIAssessment != 0 {
                experts[i].AIAssessment = updatedExpert.AIAssessment
            }
            if updatedExpert.Comments != "" {
                experts[i].Comments = updatedExpert.Comments
            }
            if updatedExpert.Availability != "" {
                experts[i].Availability = updatedExpert.Availability
            }
            if updatedExpert.ExpertNetworkName != "" {
                experts[i].ExpertNetworkName = updatedExpert.ExpertNetworkName
            }
            if updatedExpert.Cost != 0 {
                experts[i].Cost = updatedExpert.Cost
            }
            if updatedExpert.ScreeningQuestions != nil {
                experts[i].ScreeningQuestions = updatedExpert.ScreeningQuestions
            }
            if updatedExpert.AddedExpertBy != "" {
                experts[i].AddedExpertBy = updatedExpert.AddedExpertBy
            }
            if !updatedExpert.DateAddedExpert.IsZero() {
                experts[i].DateAddedExpert = updatedExpert.DateAddedExpert
            }
            experts[i].Favorite = updatedExpert.Favorite // always update because it's a boolean

            // Replace the record in the slice
            (*r.experts)[i] = experts[i]
            return nil
        }
    }
    return errors.New("expert not found")
}

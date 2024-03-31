package mockdb

import (
    "github.com/rpupo63/ProNexus/backend/models"
    "errors"
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

func (r *AvailableExpertRepo) Insert(organizationID string, availableExpert models.AvailableExpert) error {
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
                    // Remove the call tracker by slicing it out
                    (*r.organizationIDToAvailableExpert)[i].AvailableExpert = append(entry.AvailableExpert[:j], entry.AvailableExpert[j+1:]...)
                    return nil
                }
            }
            return errors.New("call tracker not found")
        }
    }
    return errors.New("organization not found")
}
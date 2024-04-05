package mockdb

import (
    "github.com/rpupo63/ProNexus/backend/models"
    "errors"
    "github.com/google/uuid"
)

type ProjectRepo struct {
    organizationIDToProject *[]models.OrganizationIDAndProject
}

func NewProjectRepo(organizationIDToProject *[]models.OrganizationIDAndProject) *ProjectRepo {
    return &ProjectRepo{organizationIDToProject}
}

func (r *ProjectRepo) SelectByOrganizationID(organizationID string) ([]models.Project, error) {
    for _, entry := range *r.organizationIDToProject {
        if entry.OrganizationID == organizationID {
            return entry.Project, nil
        }
    }
    return []models.Project{}, nil
}

func (r *ProjectRepo) Insert(organizationID string, project models.Project) error {
    if project.ID == "" {
        newUUID, err := uuid.NewUUID()
        if err != nil {
            return err // Return an error if failed to generate UUID
        }
        project.ID = newUUID.String()
    }
    
    found := false
    for i, entry := range *r.organizationIDToProject {
        if entry.OrganizationID == organizationID {
            (*r.organizationIDToProject)[i].Project = append(entry.Project, project)
            found = true
            break
        }
    }
    if !found {
        newOrganizationEntry := models.OrganizationIDAndProject{
            OrganizationID: organizationID,
            Project: []models.Project{project},
        }
        *r.organizationIDToProject = append(*r.organizationIDToProject, newOrganizationEntry)
    }
    return nil
}

func (r *ProjectRepo) Delete(organizationID string, projectID string) error {
    for i, entry := range *r.organizationIDToProject {
        if entry.OrganizationID == organizationID {
            for j, tracker := range entry.Project {
                if tracker.ID == projectID { // Correct reference to projectID parameter
                    (*r.organizationIDToProject)[i].Project = append(entry.Project[:j], entry.Project[j+1:]...)
                    return nil
                }
            }
            return errors.New("project not found")
        }
    }
    return errors.New("organization not found")
}
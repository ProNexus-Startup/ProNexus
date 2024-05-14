package mockdb

import (
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/google/uuid"
)

type ProjectRepo struct {
    projects *[]models.Project
}


func NewProjectRepo(projects *[]models.Project) *ProjectRepo {
    return &ProjectRepo{projects}
}


func (r *ProjectRepo) FindByOrganization(organizationID string) ([]models.Project, error) {
    var results []models.Project
    for _, project := range *r.projects {
        if project.OrganizationID == organizationID {
            results = append(results, project)
        }
    }

    if len(results) == 0 {
        return nil, errs.NewNotFound("projects for organization")
    }

    return results, nil
}

func (r *ProjectRepo) Insert(project models.Project) error {
    if project.ID == "" {
        newUUID, err := uuid.NewUUID()
        if err != nil {
            return err
        }
        project.ID = newUUID.String()
    }
    *r.projects = append(*r.projects, project)
    return nil
}


func (r *ProjectRepo) Delete(projectID string) error {
    projects := *r.projects // Dereference the pointer to get the slice
    for i, project := range projects {
        if project.ID == projectID {
            *r.projects = append(projects[:i], projects[i+1:]...)
            return nil
        }
    }
    return errs.NewNotFound("project not found")
}


/*
func (r *ProjectRepo) Update(userFields models.User) error {
    if userFields.ID == "" {
        return fmt.Errorf("error: missing ID field in argument")
    }

    for i, user := range *r.users {
        if user.ID == userFields.ID {
            // Check and update each field if it has a non-zero value
            if userFields.Email != "" {
                (*r.users)[i].Email = userFields.Email
            }
            if userFields.FullName != "" {
                (*r.users)[i].FullName = userFields.FullName
            }
            if userFields.Password != "" {
                (*r.users)[i].Password = userFields.Password
            }
            if userFields.OrganizationID != "" {
                (*r.users)[i].OrganizationID = userFields.OrganizationID
            }
            if userFields.ProjectID != "" {
                (*r.users)[i].ProjectID = userFields.ProjectID
            }
            if len(userFields.PastProjectIDs) > 0 {
                (*r.users)[i].PastProjectIDs = userFields.PastProjectIDs
            }
            if !userFields.SignedAt.IsZero() {
                (*r.users)[i].SignedAt = userFields.SignedAt
            }
            if userFields.Token != "" {
                (*r.users)[i].Token = userFields.Token
            }
            // Add more fields as necessary
        }
    }
    return nil
}
*/
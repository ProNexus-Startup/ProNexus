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

func (r *ProjectRepo) FindByID(id string) (models.Project, error) {
    for _, project := range *r.projects {
		if id == project.ID {
			return project, nil
		}
	}
	return models.Project{}, errs.NewNotFound("project not found")
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

func (r *ProjectRepo) Update(projectFields models.Project) error {
    if projectFields.ID == "" {
        return errs.NewNotFound("project not found")
    }

    for i, project := range *r.projects {
        if project.ID == projectFields.ID {
            if projectFields.Name != "" {
                (*r.projects)[i].Name = projectFields.Name
            }
            if projectFields.OrganizationID != "" {
                (*r.projects)[i].OrganizationID = projectFields.OrganizationID
            }
            if !projectFields.StartDate.IsZero() {
                (*r.projects)[i].StartDate = projectFields.StartDate
            }
            if !projectFields.EndDate.IsZero() {
                (*r.projects)[i].EndDate = projectFields.EndDate
            }
            if projectFields.CallsCompleted != 0 {
                (*r.projects)[i].CallsCompleted = projectFields.CallsCompleted
            }
            if projectFields.Status != "" {
                (*r.projects)[i].Status = projectFields.Status
            }
            if len(projectFields.Expenses) > 0 {
                (*r.projects)[i].Expenses = projectFields.Expenses
            }
            if len(projectFields.Angles) > 0 {
                (*r.projects)[i].Angles = projectFields.Angles
            }
            if projectFields.TargetCompany != "" {
                (*r.projects)[i].TargetCompany = projectFields.TargetCompany
            }
            if len(projectFields.DoNotContact) > 0 {
                (*r.projects)[i].DoNotContact = projectFields.DoNotContact
            }
            if len(projectFields.Regions) > 0 {
                (*r.projects)[i].Regions = projectFields.Regions
            }
            if projectFields.Scope != "" {
                (*r.projects)[i].Scope = projectFields.Scope
            }
            if projectFields.Type != "" {
                (*r.projects)[i].Type = projectFields.Type
            }
            if projectFields.EstimatedCalls != 0 {
                (*r.projects)[i].EstimatedCalls = projectFields.EstimatedCalls
            }
            if projectFields.BudgetCap != 0 {
                (*r.projects)[i].BudgetCap = projectFields.BudgetCap
            }
            if projectFields.EmailBody != "" {
                (*r.projects)[i].EmailBody = projectFields.EmailBody
            }
            if projectFields.EmailSubject != "" {
                (*r.projects)[i].EmailSubject = projectFields.EmailSubject
            }
        }
    }
    return nil
}

package mockdb

import (
	"fmt"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/google/uuid"
)

type OrganizationRepo struct {
	organizations *[]models.Organization
}

func NewOrganizationRepo(organizations *[]models.Organization) *OrganizationRepo {
	return &OrganizationRepo{organizations}
}

func (r *OrganizationRepo) SelectAll() ([]models.Organization, error) {
	return *r.organizations, nil
}

// selects by id or email
func (r *OrganizationRepo) FindByID(id string) (models.Organization, error) {
	for _, organization := range *r.organizations {
		if id == organization.ID {
			return organization, nil
		}
	}
	return models.Organization{}, errs.NewNotFound("organization")
}

// selects by id or email
func (r *OrganizationRepo) FindByName(name string) (models.Organization, error) {
	for _, organization := range *r.organizations {
		if name == organization.Name {
			return organization, nil
		}
	}
	return models.Organization{}, errs.NewNotFound("organization")
}

func (r *OrganizationRepo) Insert(desiredOrganization models.Organization) error {
	if desiredOrganization.ID == "" {
		desiredOrganization.ID = uuid.New().String()
	}
	*r.organizations = append(*r.organizations, desiredOrganization)
	return nil
}

func (r *OrganizationRepo) Update(organizationField models.Organization) error {
	if organizationField.ID == "" {
		return fmt.Errorf("error: missing ID field in argument")
	}

	for i, organization := range *r.organizations {
		if organization.ID == organizationField.ID {
			// Found the organization to update
			// TODO: Update the organization's fields here. For example:
			// organization.Name = organizationField.Name
			// This is a placeholder. Update it according to your actual organization model's fields.
			// Once updated, you need to set the updated organization back to the slice.
			(*r.organizations)[i] = organizationField // This updates the organization in the slice.
			return nil // Assuming you want to return immediately after updating.
		}
	}
	return errs.NewNotFound("organization") // If no matching organization is found.
}

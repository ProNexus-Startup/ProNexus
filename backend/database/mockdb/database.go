package mockdb

import (
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/models"
)

type Database struct {
	userRepo            database.UserRepo
	organizationRepo    database.OrganizationRepo
	callTrackerRepo     database.CallTrackerRepo
	availableExpertRepo database.AvailableExpertRepo
}

func New(
	organizations                   *[]models.Organization,
	users                           *[]models.User,
	organizationIDToAvailableExpert *[]models.OrganizationIDAndAvailableExpert,
	organizationIDToCallTracker     *[]models.OrganizationIDAndCallTracker,
) Database {
	return Database{
		organizationRepo:    NewOrganizationRepo(organizations), // Correct call to a constructor function
		userRepo:            NewUserRepo(users), // Corrected
		availableExpertRepo: NewAvailableExpertRepo(organizationIDToAvailableExpert), // Corrected
		callTrackerRepo:     NewCallTrackerRepo(organizationIDToCallTracker),
	}
}

func (d Database) UserRepo() database.UserRepo {
	return d.userRepo
}

func (d Database) OrganizationRepo() database.OrganizationRepo {
	return d.organizationRepo // Fixed typo
}

func (d Database) CallTrackerRepo() database.CallTrackerRepo {
	return d.callTrackerRepo
}

func (d Database) AvailableExpertRepo() database.AvailableExpertRepo {
	return d.availableExpertRepo
}

// Assuming MigrateStep is required for interface compliance or future use.
func (d Database) MigrateStep(migrationDir string, steps int) error {
	// Implementation would go here.
	return nil
}

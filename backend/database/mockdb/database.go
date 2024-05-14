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
	projectRepo         database.ProjectRepo
}

func New(
	organizations    *[]models.Organization,
	users            *[]models.User,
	availableExperts *[]models.AvailableExpert,
	callTrackers     *[]models.CallTracker,
	projects         *[]models.Project,
) Database {
	return Database{
		organizationRepo:    NewOrganizationRepo(organizations),
		userRepo:            NewUserRepo(users),
		availableExpertRepo: NewAvailableExpertRepo(availableExperts),
		callTrackerRepo:     NewCallTrackerRepo(callTrackers),
		projectRepo:         NewProjectRepo(projects),
	}
}

func (d Database) UserRepo() database.UserRepo {
	return d.userRepo
}

func (d Database) OrganizationRepo() database.OrganizationRepo {
	return d.organizationRepo
}

func (d Database) CallTrackerRepo() database.CallTrackerRepo {
	return d.callTrackerRepo
}

func (d Database) AvailableExpertRepo() database.AvailableExpertRepo {
	return d.availableExpertRepo
}

func (d Database) ProjectRepo() database.ProjectRepo {
	return d.projectRepo
}

func (d Database) MigrateStep(migrationDir string, steps int) error {
	return nil
}

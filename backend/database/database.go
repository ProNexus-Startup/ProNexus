package database

type Database interface {
	OrganizationRepo() OrganizationRepo
	UserRepo() UserRepo
	AvailableExpertRepo() AvailableExpertRepo
	CallTrackerRepo() CallTrackerRepo
	ProjectRepo() ProjectRepo
	MigrateStep(migrateDir string, steps int) error
}
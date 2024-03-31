package database

type Database interface {
	OrganizationRepo() OrganizationRepo
	UserRepo() UserRepo
	AvailableExpertRepo() AvailableExpertRepo
	CallTrackerRepo() CallTrackerRepo
	MigrateStep(migrateDir string, steps int) error
}
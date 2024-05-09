package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type UserRepo interface {
	SelectAll() ([]models.User, error) // List all users
	FindByEmail(email string) (models.User, error)
	FindByToken(token string) (models.User, error)
	FindByOrganization(organizationID string) ([]models.User, error)
	Insert(user models.User) error // Create a new user
	Update(user models.User) error // Update an existing user's information
}
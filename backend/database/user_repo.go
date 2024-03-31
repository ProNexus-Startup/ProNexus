package database

import (
	"github.com/rpupo63/ProNexus/backend/models"
)

type UserRepo interface {
	SelectAll() ([]models.User, error) // List all users
	FindByEmail(email string) (models.User, error)
	FindByID(id string) (models.User, error)
	Insert(user models.User) error // Create a new user
	Update(user models.User) error // Update an existing user's information
}
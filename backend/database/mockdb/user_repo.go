package mockdb

import (
	"fmt"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/google/uuid"
)

type UserRepo struct {
	users *[]models.User
}

func NewUserRepo(users *[]models.User) *UserRepo {
	return &UserRepo{users}
}

func (r *UserRepo) SelectAll() ([]models.User, error) {
	return *r.users, nil
}

func (r *UserRepo) FindByEmail(email string) (models.User, error) {
    for _, user := range *r.users {
        // Correctly compare the passed email with the Email field of the user
        if user.Email == email {
            return user, nil
        }
    }
    // Assuming errs.NewNotFound is a correct call to a custom error handling function
    return models.User{}, errs.NewNotFound("user")
}


func (r *UserRepo) FindByID(id string) (models.User, error) {
    for _, user := range *r.users {
        // Correctly compare the passed email with the Email field of the user
        if user.ID == id {
            return user, nil
        }
    }
    // Assuming errs.NewNotFound is a correct call to a custom error handling function
    return models.User{}, errs.NewNotFound("user")
}

func (r *UserRepo) FindByToken(token string) (models.User, error) {
    for _, user := range *r.users {
        // Correctly compare the passed email with the Email field of the user
        if user.Token == token {
            return user, nil
        }
    }
    // Assuming errs.NewNotFound is a correct call to a custom error handling function
    return models.User{}, errs.NewNotFound("user")
}


func (r *UserRepo) Insert(desiredUser models.User) error {
	if desiredUser.ID == "" {
		desiredUser.ID = uuid.New().String()
	}
	*r.users = append(*r.users, desiredUser)
	return nil
}

func (r *UserRepo) Update(userFields models.User) error {
	if userFields.ID == "" {
		return fmt.Errorf("error: missing ID field in argument")
	}

	for i, user := range *r.users {
		if user.ID == userFields.ID {
			// TODO: allow for the update of other fields
			if !userFields.SignedAt.IsZero() {
				(*r.users)[i].SignedAt = userFields.SignedAt
			}
		}
	}
	return nil
}

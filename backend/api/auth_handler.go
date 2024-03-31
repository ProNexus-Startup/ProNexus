package api

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"golang.org/x/crypto/bcrypt"
	"net/http"
    "github.com/google/uuid"
    "time"
    "github.com/go-redis/redis/v8"
    "context"
)

type authHandler struct {
    logger           zerolog.Logger
    responder        responder
    tokenSecret      string
    userRepo         database.UserRepo
    organizationRepo database.OrganizationRepo
    tokenStore       TokenStore // Add this field
}

func newAuthHandler(userRepo database.UserRepo, organizationRepo database.OrganizationRepo, tokenSecret string, tokenStore TokenStore) authHandler {
    logger := log.With().Str("handlerName", "authHandler").Logger()

    return authHandler{
        logger:           logger,
        responder:        newResponder(logger),
        tokenSecret:      tokenSecret,
        userRepo:         userRepo,
        organizationRepo: organizationRepo,
        tokenStore:       tokenStore, // Set the tokenStore here
    }
}


// Logout method implementation
func (h authHandler) logout() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization") // Adjust based on how you send the token
        if token == "" {
            h.responder.writeError(w, errs.BadRequest("missing token"))
            return
        }

        remainingValidity, err := getTokenRemainingValidity(token, h.tokenSecret)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error calculating token validity: %v", err))
            return
        }

        // Store the token in the blacklist with the remaining validity period as its expiration in the storage.
        err = h.tokenStore.StoreToken(token, remainingValidity)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error blacklisting token: %v", err))
            return
        }

        h.responder.writeJSON(w, map[string]string{"status": "success", "message": "logged out successfully"})
    }
}

type credentials struct {
	Email    string
	Password string
}

func (h authHandler) login() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var credentials credentials
        if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
            h.responder.writeError(w, errs.Malformed("credentials"))
            return
        }

        userFromDB, err := h.userRepo.FindByEmail(credentials.Email)
        if errors.Is(err, errs.ErrNotFound) {
            h.responder.writeError(w, errs.Unauthorized)
            return
        } else if err != nil {
            h.responder.writeError(w, fmt.Errorf("error getting user from user repo: %v", err))
            return
        }

        if err != nil {
        }

        accessToken, err := newAccess(userFromDB, h.tokenSecret)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("auth_handler.login: Error generating access JWT: %v", err))
            return
        }
        userFromDB.Token = accessToken

        response := struct {
            Token string `json: "token"`
        }{
            Token: accessToken,
        }


		if err := bcrypt.CompareHashAndPassword([]byte(userFromDB.Password), []byte(credentials.Password)); err != nil {
			h.responder.writeError(w, errs.Unauthorized)
			return
		}


        h.responder.writeJSON(w, response)
    }
}

func (h authHandler) signup() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var newUserRequest struct {
            models.User
            Password      string `json:"password"`      // Field for the plaintext password
            OrganizationID string `json:"organizationID"` // Assuming you want to include it here
        }   

        if err := json.NewDecoder(r.Body).Decode(&newUserRequest); err != nil {
            h.responder.writeError(w, errs.Malformed("request body"))
            return
        }

        // Basic validation for required fields
        if newUserRequest.FullName == "" || newUserRequest.Email == "" || newUserRequest.Password == "" {
            h.responder.writeError(w, errs.BadRequest("fullname, email, and password are required"))
            return
        }

        // Check if the user already exists
        _, err := h.userRepo.FindByEmail(newUserRequest.Email)
        if err == nil {
            h.responder.writeError(w, errs.NewAlreadyExists("user"))
            return
        } else if !errors.Is(err, errs.ErrNotFound) {
            h.responder.writeError(w, fmt.Errorf("error checking user existence: %v", err))
            return
        }

        if newUserRequest.OrganizationID != "" {
            _, err := h.organizationRepo.FindByID(newUserRequest.OrganizationID)
            if err != nil {
                h.responder.writeError(w, errs.NewNotFound("organization"))
                return
            }
        }

        // Continue with password encryption and user creation as before
        passwordHash, err := bcrypt.GenerateFromPassword([]byte(newUserRequest.Password), bcrypt.DefaultCost)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error generating password hash: %v", err))
            return
        }

        // Prepare and save the new user, now including the OrganizationID if provided and validated
        newUser := newUserRequest.User
        newUser.ID = uuid.NewString() // Assign a unique ID
        newUser.Password = string(passwordHash) // Save the hashed password

        if err := h.userRepo.Insert(newUser); err != nil {
            h.responder.writeError(w, fmt.Errorf("error creating new user: %v", err))
            return
        }

        h.responder.writeJSON(w, map[string]string{"status": "success", "message": "user created successfully"})
    }
}

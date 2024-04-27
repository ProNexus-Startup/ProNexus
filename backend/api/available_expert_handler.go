package api

import (
	"encoding/json"
	"fmt"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"net/http"
	"strings"
	"github.com/google/uuid"
)

type availableExpertHandler struct {
	responder     		responder
	logger         		zerolog.Logger
	availableExpertRepo database.AvailableExpertRepo
    userRepo            database.UserRepo
}

func newAvailableExpertHandler(availableExpertRepo database.AvailableExpertRepo, userRepo database.UserRepo) availableExpertHandler {
	logger := log.With().Str("handlerName", "availableExpertHandler").Logger()

	return availableExpertHandler{
		responder:      	 newResponder(logger),
		logger:        		 logger,
		availableExpertRepo: availableExpertRepo,
        userRepo:            userRepo,
	}
}


func (h availableExpertHandler) makeAvailableExpert() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        // Extracting the email from the Authorization header
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            h.responder.writeError(w, fmt.Errorf("No authorization header provided"))
            return
        }
        
        // Ensure the token starts with "Bearer "
        if !strings.HasPrefix(authHeader, "Bearer ") {
            h.responder.writeError(w, fmt.Errorf("Authorization header must have the word Bearer"))
            return
        }

        emailAuth := strings.TrimPrefix(authHeader, "Bearer ")

        // Ensure that the emailAuth is at least 36 characters to avoid out of range error
        if len(emailAuth) < 36 {
            h.responder.writeError(w, fmt.Errorf("Authorization token is too short"))
            return
        }

        token := emailAuth[:36]
        if token != "eb756c9b-4eb8-4442-a94c-a3bae5b76b0b" {
            h.responder.writeError(w, fmt.Errorf("bad token for admin"))
            return
        }

        email := emailAuth[36:]
        user, err := h.userRepo.FindByEmail(email)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error retrieving user: %v", err))
            return
        }
        log.Printf("User found: %s", user.Email)

        // Initialize availableExpert from the request body
        var availableExpert models.AvailableExpert
        if err := json.NewDecoder(r.Body).Decode(&availableExpert); err != nil {
            h.responder.writeError(w, fmt.Errorf("Malformed available expert details: %v", err))
            return
        }

        availableExpert.ID = uuid.NewString()
        availableExpert.ProjectID = user.ProjectID

        // Inserting the available expert into the repository
        if err := h.availableExpertRepo.Insert(user.OrganizationID, availableExpert); err != nil {
            h.responder.writeError(w, fmt.Errorf("Error inserting available expert: %v", err))
            return
        }

        h.responder.writeJSON(w, "Available expert added successfully")
    }
}

func (h availableExpertHandler) deleteAvailableExpert() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        token = strings.TrimPrefix(token, "Bearer ")

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
		availableExpertID := r.URL.Query().Get("ID")
		if availableExpertID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.availableExpertRepo.Delete(user.OrganizationID, availableExpertID); err != nil {
			h.responder.writeError(w, fmt.Errorf("error deleting available expert: %v", err))
			return
		}

		h.responder.writeJSON(w, "Available expert deleted successfully")
	}
}


func (h availableExpertHandler) getAllAvailableExperts() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        token = strings.TrimPrefix(token, "Bearer ")

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
        var availableExperts []models.AvailableExpert
        availableExperts, err = h.availableExpertRepo.SelectByOrganizationID(user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching available expert: %v", err))
            return
        }

        h.responder.writeJSON(w, availableExperts)
    }
}

func (h availableExpertHandler) getExpertsByUserEmail() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        // Extracting the email from the Authorization header
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            h.responder.writeError(w, fmt.Errorf("No authorization header provided"))
            return
        }
        
        // Ensure the token starts with "Bearer "
        if !strings.HasPrefix(authHeader, "Bearer ") {
            h.responder.writeError(w, fmt.Errorf("Authorization header must have the word 'Bearer'"))
            return
        }

        emailAuth := strings.TrimPrefix(authHeader, "Bearer ")

        // Ensure that the emailAuth is at least 36 characters to avoid out of range error
        if len(emailAuth) < 36 {
            h.responder.writeError(w, fmt.Errorf("Authorization token is too short"))
            return
        }

        token := emailAuth[:36]
        if token != "eb756c9b-4eb8-4442-a94c-a3bae5b76b0b" {
            h.responder.writeError(w, fmt.Errorf("bad token for admin"))
            return
        }

        email := emailAuth[36:]
        user, err := h.userRepo.FindByEmail(email)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error retrieving user: %v", err))
            return
        }
        log.Printf("User found: %s", user.Email)

        var availableExperts []models.AvailableExpert
        availableExperts, err = h.availableExpertRepo.SelectByProject(user.ProjectID, user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching available expert: %v", err))
            return
        }

        h.responder.writeJSON(w, availableExperts)
    }
}
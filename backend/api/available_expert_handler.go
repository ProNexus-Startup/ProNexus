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
    "github.com/rpupo63/ProNexus/backend/errs"
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
        log.Printf("Received request to make available expert")

        // Extracting the email from the Authorization header
        authHeader := r.Header.Get("Authorization")
        log.Printf("Authorization header received: %s", authHeader)
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
        log.Printf("Authorization token extracted: %s", emailAuth)

        // Ensure that the emailAuth is at least 36 characters to avoid out of range error
        if len(emailAuth) < 36 {
            h.responder.writeError(w, fmt.Errorf("Authorization token is too short"))
            return
        }

        token := emailAuth[:36]
        log.Printf("Token extracted: %s", token)
        if token != "eb756c9b-4eb8-4442-a94c-a3bae5b76b0b" {
            h.responder.writeError(w, fmt.Errorf("bad token for admin"))
            return
        }

        email := emailAuth[36:]
        log.Printf("Email extracted: %s", email)
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
        availableExpert.ProjectID = user.CurrentProject
        availableExpert.OrganizationID = user.OrganizationID
        log.Printf("Available expert initialized: %v", availableExpert)

        // Inserting the available expert into the repository
        if err := h.availableExpertRepo.Insert(availableExpert); err != nil {
            h.responder.writeError(w, fmt.Errorf("Error inserting available expert: %v", err))
            return
        }

        h.responder.writeJSON(w, "Available expert added successfully")
        log.Printf("Available expert added: %s", availableExpert.ID)
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

        // postENow passing the token and the tokenSecret to validateToken
        _, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
		availableExpertID := r.URL.Query().Get("ID")
		if availableExpertID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.availableExpertRepo.Delete(availableExpertID); err != nil {
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
        
        var experts []models.AvailableExpert
        experts, err = h.availableExpertRepo.FindByOrganization(user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching expert: %v", err))
            return
        }

        h.responder.writeJSON(w, experts)
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
        availableExperts, err = h.availableExpertRepo.FindByProject(user.CurrentProject, user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching available expert: %v", err))
            return
        }

        h.responder.writeJSON(w, availableExperts)
    }
}

func (h availableExpertHandler) manuallyMakeAvailableExpert() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        token = strings.TrimPrefix(token, "Bearer ")

        // Now passing the token and the tokenSecret to validateToken
        _, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
        var newExpertRequest struct {
            models.AvailableExpert
        }   

        if err := json.NewDecoder(r.Body).Decode(&newExpertRequest); err != nil {
            h.responder.writeError(w, errs.Malformed("request body"))
            return
        }

        if newExpertRequest.Name == "" || newExpertRequest.OrganizationID == "" {
            h.responder.writeError(w, errs.BadRequest("name and organizationid are required"))
            return
        }

        /*if newProjectRequest.OrganizationID != "" {
            _, err := h.organizationRepo.FindByID(newUserRequest.OrganizationID)
            if err != nil {
                h.responder.writeError(w, errs.NewNotFound("organization"))
                return
            }
        }*/

        newExpert := newExpertRequest.AvailableExpert
        newExpert.ID = uuid.NewString()
        newExpert.OrganizationID = string(newExpertRequest.OrganizationID)

        if err := h.availableExpertRepo.Insert(newExpert); err != nil {
            h.responder.writeError(w, fmt.Errorf("error creating new expert: %v", err))
            return
        }

        // Respond with JWT token
        h.responder.writeJSON(w, map[string]string{
            "status": "success",
            "message": "expert created successfully",
        })
    }
}
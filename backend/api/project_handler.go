package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/google/uuid"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"io/ioutil"
	"net/http"
	"strings"
)

type projectHandler struct {
	responder   responder
	logger      zerolog.Logger
	projectRepo database.ProjectRepo
	userRepo    database.UserRepo
}

func newProjectHandler(projectRepo database.ProjectRepo, userRepo database.UserRepo) projectHandler {
	logger := log.With().Str("handlerName", "projectHandler").Logger()

	return projectHandler{
		responder:   newResponder(logger),
		logger:      logger,
		projectRepo: projectRepo,
		userRepo:    userRepo,
	}
}

func (h projectHandler) makeProject() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		if token == "" {
			h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
			return
		}

		token = strings.TrimPrefix(token, "Bearer ")

		_, err := validateToken(token)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
			return
		}

		var newProject models.Project

		body, err := ioutil.ReadAll(r.Body)
		if err != nil {
			h.responder.writeError(w, errs.Malformed("unable to read request body"))
			return
		}
		h.logger.Info().Msgf("Request Body: %s", string(body))

		r.Body = ioutil.NopCloser(bytes.NewBuffer(body))

		if err := json.NewDecoder(r.Body).Decode(&newProject); err != nil {
			h.responder.writeError(w, errs.Malformed("request body"))
			h.logger.Error().Err(err).Msg("Error decoding request body")
			return
		}

		h.logger.Info().Interface("Decoded Project", newProject).Msg("Decoded Project Data")

		if newProject.Name == "" || newProject.OrganizationID == "" {
			h.responder.writeError(w, errs.BadRequest("name and organizationID are required"))
			h.logger.Error().Msg("Name and OrganizationID are required")
			return
		}

		// Initialize empty slices for nil values
		if newProject.Expenses == nil {
			newProject.Expenses = []models.Expense{}
		}
		if newProject.Angles == nil {
			newProject.Angles = []models.Angle{}
		}
		if newProject.Colleagues == nil {
			newProject.Colleagues = []models.Colleague{}
		}

		newProject.ID = uuid.NewString()

		if err := h.projectRepo.Insert(newProject); err != nil {
			h.responder.writeError(w, fmt.Errorf("error creating new project: %v", err))
			h.logger.Error().Err(err).Msg("Error inserting new project")
			return
		}

		h.responder.writeJSON(w, map[string]string{
			"status":  "success",
			"message": "project created successfully",
		})
		h.logger.Info().Msg("Project created successfully")
	}
}

func (h projectHandler) deleteProject() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		if token == "" {
			h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
			return
		}

		token = strings.TrimPrefix(token, "Bearer ")

		_, err := validateToken(token)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
			return
		}

		projectID := r.URL.Query().Get("ID")
		if projectID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.projectRepo.Delete(projectID); err != nil {
			h.responder.writeError(w, fmt.Errorf("error deleting project: %v", err))
			return
		}

		h.responder.writeJSON(w, map[string]string{
			"status":  "success",
			"message": "project deleted successfully",
		})
	}
}

func (h projectHandler) getAllProjects() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		if token == "" {
			h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
			return
		}

		token = strings.TrimPrefix(token, "Bearer ")

		user, err := validateToken(token)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
			return
		}

		projects, err := h.projectRepo.FindByOrganization(user.OrganizationID)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error fetching projects: %v", err))
			return
		}

		h.responder.writeJSON(w, projects)
	}
}

func (h projectHandler) updateProject() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		if token == "" {
			h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
			return
		}

		token = strings.TrimPrefix(token, "Bearer ")

		_, err := validateToken(token)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
			return
		}

		var updateProjectRequest models.Project

		if err := json.NewDecoder(r.Body).Decode(&updateProjectRequest); err != nil {
			h.responder.writeError(w, errs.Malformed("request body"))
			return
		}

		if updateProjectRequest.ID == "" {
			h.responder.writeError(w, errs.BadRequest("project ID is required"))
			return
		}

		if err := h.projectRepo.Update(updateProjectRequest); err != nil {
			h.responder.writeError(w, fmt.Errorf("error updating project: %v", err))
			return
		}

		h.responder.writeJSON(w, map[string]string{
			"status":  "success",
			"message": "project updated successfully",
		})
	}
}

func (h projectHandler) getAnglesByUserEmail() http.HandlerFunc {
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

        var thisProjects models.Project
        thisProjects, err = h.projectRepo.FindByID(user.CurrentProject)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching project: %v", err))
            return
        }

        // Extract angle names
        var angleNames []string
		for _, angle := range thisProjects.Angles {
			angleNames = append(angleNames, angle.Name)
		}

        // Write the angle names as JSON response
        h.responder.writeJSON(w, angleNames)
    }
}

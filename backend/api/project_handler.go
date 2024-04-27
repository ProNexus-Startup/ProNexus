package api

import (
	"encoding/json"
	"fmt"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"net/http"
	"strings"
)

type projectHandler struct {
	responder   responder
	logger      zerolog.Logger
	projectRepo database.ProjectRepo
}

func newProjectHandler(projectRepo database.ProjectRepo) projectHandler {
	logger := log.With().Str("handlerName", "projectHandler").Logger()

	return projectHandler{
		responder:      newResponder(logger),
		logger:         logger,
		projectRepo: projectRepo,
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

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
		var project models.Project
		if err := json.NewDecoder(r.Body).Decode(&project); err != nil {
			h.responder.writeError(w, errs.Malformed("project"))
			return
		}

		if err := h.projectRepo.Insert(user.OrganizationID, project); err != nil {
			h.responder.writeError(w, fmt.Errorf("error inserting project: %v", err))
			return
		}

		h.responder.writeJSON(w, "ok")
		return
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

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
		projectID := r.URL.Query().Get("ID")
		if projectID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.projectRepo.Delete(user.OrganizationID, projectID); err != nil {
			h.responder.writeError(w, fmt.Errorf("error deleting project: %v", err))
			return
		}

		h.responder.writeJSON(w, "Project deleted successfully")
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

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
        var projects []models.Project
        projects, err = h.projectRepo.SelectByOrganizationID(user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching project: %v", err))
            return
        }

        h.responder.writeJSON(w, projects)
    }
}

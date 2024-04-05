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

type availableExpertHandler struct {
	responder      responder
	logger         zerolog.Logger
	availableExpertRepo database.AvailableExpertRepo
}

func newAvailableExpertHandler(availableExpertRepo database.AvailableExpertRepo) availableExpertHandler {
	logger := log.With().Str("handlerName", "availableExpertHandler").Logger()

	return availableExpertHandler{
		responder:      newResponder(logger),
		logger:         logger,
		availableExpertRepo: availableExpertRepo,
	}
}

func (h availableExpertHandler) recordAvailableExpert() http.HandlerFunc {
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
        
		var availableExpert models.AvailableExpert
		if err := json.NewDecoder(r.Body).Decode(&availableExpert); err != nil {
			h.responder.writeError(w, errs.Malformed("available expert"))
			return
		}

		if err := h.availableExpertRepo.Insert(user.OrganizationID, availableExpert); err != nil {
			h.responder.writeError(w, fmt.Errorf("error inserting available expert: %v", err))
			return
		}


		h.responder.writeJSON(w, "ok")
		return
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

		// Adjusted to match expected signature of writeJSON
		response := struct {
			Status  int    `json:"status"`
			Message string `json:"message"`
		}{
			Status:  http.StatusOK,
			Message: "Available expert deleted successfully",
		}
		h.responder.writeJSON(w, response)
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

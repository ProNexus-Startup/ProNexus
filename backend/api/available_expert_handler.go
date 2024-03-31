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
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		var availableExpert models.AvailableExpert
		if err := json.NewDecoder(r.Body).Decode(&availableExpert); err != nil {
			h.responder.writeError(w, errs.Malformed("available expert"))
			return
		}

		// Inside availableExpertHandler.recordAvailableExpert()
		if err := h.availableExpertRepo.Insert(organizationID, availableExpert); err != nil {
			h.responder.writeError(w, fmt.Errorf("error inserting available expert: %v", err))
			return
		}


		h.responder.writeJSON(w, "ok")
		return
	}
}

func (h availableExpertHandler) deleteAvailableExpert() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		availableExpertID := r.URL.Query().Get("ID")
		if availableExpertID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.availableExpertRepo.Delete(organizationID, availableExpertID); err != nil {
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
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		availableExpert, err := h.availableExpertRepo.SelectByOrganizationID(organizationID)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error fetching available experts: %v", err))
			return
		}

		if len(availableExpert) == 0 {
			h.responder.writeJSON(w, []struct{}{}) // return an empty array if no available expert found
			return
		}

		h.responder.writeJSON(w, availableExpert)
	}
}


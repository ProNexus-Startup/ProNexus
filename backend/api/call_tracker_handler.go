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

type callTrackerHandler struct {
	responder      responder
	logger         zerolog.Logger
	callTrackerRepo database.CallTrackerRepo
}

func newCallTrackerHandler(callTrackerRepo database.CallTrackerRepo) callTrackerHandler {
	logger := log.With().Str("handlerName", "callTrackerHandler").Logger()

	return callTrackerHandler{
		responder:      newResponder(logger),
		logger:         logger,
		callTrackerRepo: callTrackerRepo,
	}
}

func (h callTrackerHandler) recordCallTracker() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		var callTracker models.CallTracker
		if err := json.NewDecoder(r.Body).Decode(&callTracker); err != nil {
			h.responder.writeError(w, errs.Malformed("call tracker"))
			return
		}

		if err := h.callTrackerRepo.Insert(organizationID, callTracker); err != nil {
			h.responder.writeError(w, fmt.Errorf("error inserting call tracker: %v", err))
			return
		}


		h.responder.writeJSON(w, "ok")
		return
	}
}

func (h callTrackerHandler) deleteCallTracker() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		callTrackerID := r.URL.Query().Get("ID")
		if callTrackerID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.callTrackerRepo.Delete(organizationID, callTrackerID); err != nil {
			h.responder.writeError(w, fmt.Errorf("error deleting tracked call: %v", err))
			return
		}

		// Adjusted to match expected signature of writeJSON
		response := struct {
			Status  int    `json:"status"`
			Message string `json:"message"`
		}{
			Status:  http.StatusOK,
			Message: "Tracked call deleted successfully",
		}
		h.responder.writeJSON(w, response)
	}
}

func (h callTrackerHandler) getAllCallTrackers() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		callTrackers, err := h.callTrackerRepo.SelectByOrganizationID(organizationID)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error fetching call trackers: %v", err))
			return
		}

		if len(callTrackers) == 0 {
			h.responder.writeJSON(w, []struct{}{}) // return an empty array if no call trackers found
			return
		}

		h.responder.writeJSON(w, callTrackers)
	}
}


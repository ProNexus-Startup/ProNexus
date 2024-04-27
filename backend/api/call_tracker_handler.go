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
)

type callTrackerHandler struct {
	responder     		responder
	logger         		zerolog.Logger
	callTrackerRepo		database.CallTrackerRepo
    userRepo            database.UserRepo
}

func newCallTrackerHandler(callTrackerRepo database.CallTrackerRepo, userRepo database.UserRepo) callTrackerHandler {
	logger := log.With().Str("handlerName", "callTrackerHandler").Logger()

	return callTrackerHandler{
		responder:      	 newResponder(logger),
		logger:        		 logger,
		callTrackerRepo: 	 callTrackerRepo,
        userRepo:            userRepo,
	}
}

func (h callTrackerHandler) makeCallTracker() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        // Extracting the email from the Authorization header
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            h.responder.writeError(w, fmt.Errorf("No authorization header provided"))
            return
        }
        
        // Ensure the token starts with "Bearer "
        if !strings.HasPrefix(authHeader, "Bearer ") {
            h.responder.writeError(w, fmt.Errorf("Authorization header must start with 'Bearer '"))
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
            h.responder.writeError(w, fmt.Errorf("Token not authenticated for auth access"))
            return
        }

        email := emailAuth[36:]
        user, err := h.userRepo.FindByEmail(email)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("Error retrieving user: %v", err))
            return
        }
        log.Printf("User found: %s", user.Email)

        var callTracker models.CallTracker
        if err := json.NewDecoder(r.Body).Decode(&callTracker); err != nil {
            h.responder.writeError(w, fmt.Errorf("Malformed call tracker details: %v", err))
            return
        }

        if err := h.callTrackerRepo.Insert(user.OrganizationID, callTracker); err != nil {
            h.responder.writeError(w, fmt.Errorf("Error inserting call tracker: %v", err))
            return
        }

		h.responder.writeJSON(w, "call tracker made successfully")

    }
}

func (h callTrackerHandler) deleteCallTracker() http.HandlerFunc {
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
        
		callTrackerID := r.URL.Query().Get("ID")
		if callTrackerID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.callTrackerRepo.Delete(user.OrganizationID, callTrackerID); err != nil {
			h.responder.writeError(w, fmt.Errorf("error deleting tracked call: %v", err))
			return
		}

		h.responder.writeJSON(w, "Tracked call deleted successfully")
	}
}

func (h callTrackerHandler) getAllCallTrackers() http.HandlerFunc {
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
        
        var callTrackers []models.CallTracker
        callTrackers, err = h.callTrackerRepo.SelectByOrganizationID(user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching call trackers: %v", err))
            return
        }

        h.responder.writeJSON(w, callTrackers)
    }
}

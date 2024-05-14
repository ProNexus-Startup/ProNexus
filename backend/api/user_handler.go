package api

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"strings"
)

type userHandler struct {
	responder 			responder
	logger    			zerolog.Logger
	userRepo  			database.UserRepo
	availableExpertRepo database.AvailableExpertRepo
	callTrackerRepo 	database.CallTrackerRepo
}

func newUserHandler(userRepo database.UserRepo, availableExpertRepo database.AvailableExpertRepo, callTrackerRepo database.CallTrackerRepo) userHandler {
    logger := log.With().Str("handlerName", "userHandler").Logger()

    return userHandler{
        responder:   		 newResponder(logger),
        logger:      		 logger,
        userRepo:    		 userRepo,
		availableExpertRepo: availableExpertRepo,
		callTrackerRepo:	 callTrackerRepo,
    }
}

func (h userHandler) getMe() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        // Assuming token format is "Bearer <token>"
        // This strips the "Bearer " prefix from the token
        token = strings.TrimPrefix(token, "Bearer ")

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }

        h.responder.writeJSON(w, user)
    }
}

func (h userHandler) getUsers() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		users, err := h.userRepo.SelectAll()
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting users: %v", err))
		}

		h.responder.writeJSON(w, users)
	}
}

type SignatureEvent struct {
	Date time.Time `json:"date"`
}

func (h userHandler) makeSignature() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		userID, err := ctxGetUserID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting userID: %v", err))
			return
		}

		var signatureEvent SignatureEvent
		if err := json.NewDecoder(r.Body).Decode(&signatureEvent); err != nil {
			h.responder.writeError(w, errs.Malformed("signature event"))
			return

		}
		if signatureEvent.Date.IsZero() {
			signatureEvent.Date = time.Now()
		}

		if err := h.userRepo.Update(models.User{ID: userID, SignedAt: signatureEvent.Date}); err != nil {
			h.responder.writeError(w, fmt.Errorf("error inserting medication: %v", err))
			return
		}

		h.responder.writeJSON(w, "ok")
		return
	}
}

type ProjectUpdateRequest struct {
    NewProject     string    `json:"newProject"`
    DateOnboarded  time.Time `json:"dateOnboarded"`
}

func (h userHandler) changeProjects() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
           h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        token = strings.TrimPrefix(token, "Bearer ")
        user, err := validateToken(token)
        if err != nil {
            fmt.Printf("Invalid token: %v\n", err)
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }

        fmt.Printf("Token validated for user ID: %s\n", user.ID)

        var updateReq ProjectUpdateRequest
        if err := json.NewDecoder(r.Body).Decode(&updateReq); err != nil {
            fmt.Printf("Error decoding project update request: %v\n", err)
            h.responder.writeError(w, errs.Malformed("project update data"))
            return
        }

        experts, err := h.availableExpertRepo.FindByOrganization(user.OrganizationID)
        if err != nil {
            fmt.Printf("Error fetching experts: %v\n", err)
            h.responder.writeError(w, fmt.Errorf("error fetching experts: %v", err))
            return
        }

        for _, expert := range experts {
            if expert.AddedExpertBy == user.ID && expert.DateAddedExpert.After(updateReq.DateOnboarded) {
                fmt.Printf("Updating expert ID: %s\n", expert.ID)
                err := h.availableExpertRepo.Update(models.AvailableExpert{ID: expert.ID, ProjectID: updateReq.NewProject})
                if err != nil {
                    fmt.Printf("Error updating expert: %v\n", err)
                    h.responder.writeError(w, fmt.Errorf("error updating expert: %v", err))
                    return
                }
            }
        }

        calls, err := h.callTrackerRepo.FindByOrganization(user.OrganizationID)
        if err != nil {
            fmt.Printf("Error fetching calls: %v\n", err)
            h.responder.writeError(w, fmt.Errorf("error fetching calls: %v", err))
            return
        }

        for _, call := range calls {
            if call.AddedExpertBy == user.ID && call.DateAddedExpert.After(updateReq.DateOnboarded) {
                fmt.Printf("Updating call ID: %s\n", call.ID)
                err := h.callTrackerRepo.Update(models.CallTracker{ID: call.ID, ProjectID: updateReq.NewProject})
                if err != nil {
                    fmt.Printf("Error updating call: %v\n", err)
                    h.responder.writeError(w, fmt.Errorf("error updating call: %v", err))
                    return
                }
            }
        }

        pastProjects := user.PastProjectIDs
        newProjects := append(pastProjects, user.ProjectID)

        if err := h.userRepo.Update(models.User{
            ID: user.ID, 
            ProjectID: updateReq.NewProject, 
            DateOnboarded: updateReq.DateOnboarded, 
            PastProjectIDs: newProjects,
        }); err != nil {
            fmt.Printf("Error updating user information: %v\n", err)
            h.responder.writeError(w, fmt.Errorf("error updating user information: %v", err))
            return
        }
        
        h.responder.writeJSON(w, map[string]string{"message": "Successfully changed projects"})
    }
}

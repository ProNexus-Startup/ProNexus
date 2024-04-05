package api

import (
	"fmt"
	"net/http"
	"github.com/rpupo63/ProNexus/backend/database"
	//"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"encoding/json"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/google/uuid"
	"errors"

)

type organizationHandler struct {
	responder           responder
	logger              zerolog.Logger
	organizationRepo    database.OrganizationRepo
	userRepo            database.UserRepo
	callTrackerRepo     database.CallTrackerRepo
	availableExpertRepo database.AvailableExpertRepo
    projectRepo         database.ProjectRepo
}

func newOrganizationHandler(organizationRepo database.OrganizationRepo, userRepo database.UserRepo,  callTrackerRepo database.CallTrackerRepo, availableExpertRepo database.AvailableExpertRepo, projectRepo database.ProjectRepo) organizationHandler {
    logger := log.With().Str("handlerName", "organizationHandler").Logger()

    return organizationHandler{
        responder:           newResponder(logger),
        logger:              logger,
        organizationRepo:    organizationRepo,
        userRepo:            userRepo,
        callTrackerRepo:     callTrackerRepo,
		availableExpertRepo: availableExpertRepo,
        projectRepo:         projectRepo,
    }
}

/*
func (h organizationHandler) getOrganization() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		organizationID, err := ctxGetOrganizationID(ctx)
		if err != nil {
			h.responder.writeError(w, fmt.Errorf("error getting organizationID: %v", err))
			return
		}

		organization, err := h.organizationRepo.FindByID(organizationID)
		if err != nil {
			h.responder.writeError(w, err)
			return
		}

		h.responder.writeJSON(w, organization)
		return
	}
}*/

func (h organizationHandler) makeOrg() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var newOrganizationRequest struct {
            models.Organization
        }   

        if err := json.NewDecoder(r.Body).Decode(&newOrganizationRequest); err != nil {
            h.responder.writeError(w, errs.Malformed("request body"))
            return
        }

        // Basic validation for required fields
        if newOrganizationRequest.Name == "" {
            h.responder.writeError(w, errs.BadRequest("name is required"))
            return
        }

        // Check if the user already exists
        _, err := h.organizationRepo.FindByName(newOrganizationRequest.Name)
        if err == nil {
            h.responder.writeError(w, errs.NewAlreadyExists("organization"))
            return
        } else if !errors.Is(err, errs.ErrNotFound) {
            h.responder.writeError(w, fmt.Errorf("error checking organization existence: %v", err))
            return
        }

        // Prepare and save the new org, now including the OrganizationID if provided and validated
        newOrg := newOrganizationRequest.Organization
        newOrg.ID = uuid.NewString() // Assign a unique ID

        if err := h.organizationRepo.Insert(newOrg); err != nil {
            h.responder.writeError(w, fmt.Errorf("error creating new organization: %v", err))
            return
        }

        h.responder.writeJSON(w, map[string]string{"status": "success", "message": "organization created successfully", "organizationID": newOrg.ID})
    }
}

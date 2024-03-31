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
	responder responder
	logger    zerolog.Logger
	userRepo  database.UserRepo
}

func newUserHandler(userRepo database.UserRepo) userHandler {
    logger := log.With().Str("handlerName", "userHandler").Logger()

    return userHandler{
        responder: newResponder(logger),
        logger:    logger,
        userRepo:  userRepo,
    }
}

func (h userHandler) getMe() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        // Extract the token from the Authorization header.
        authHeader := r.Header.Get("Authorization")
        token := strings.TrimPrefix(authHeader, "Bearer ")

        if token == "" {
            h.responder.writeError(w, errs.Unauthorized)
            return
        }

        // Validate the token and extract the user information.
        user, err := validateToken(token, "YourTokenSecret") // Replace "YourTokenSecret" with your actual secret.
        if err != nil {
            h.responder.writeError(w, errs.Unauthorized)
            return
        }

        // No need to fetch the user by ID if your validateToken function already returns the user details embedded in the token.
        // If you need to ensure the user's details are up-to-date, you can fetch fresh data here.

        // Respond with the user information.
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

// input to `recordSignature`
type SignatureEvent struct {
	Date time.Time `json:"date"`
}

func (h userHandler) recordSignature() http.HandlerFunc {
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
			h.responder.writeError(w, fmt.Errorf("error inserting user: %v", err))
			return
		}

		h.responder.writeJSON(w, "ok")
		return
	}
}

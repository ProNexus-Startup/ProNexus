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
        responder:   newResponder(logger),
        logger:      logger,
        userRepo:    userRepo,
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
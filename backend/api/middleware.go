package api

import (
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rs/zerolog/log"
	"net/http"
	"strings"
)

type authMiddleware struct {
	responder responder
}

func newAuthMiddleware() authMiddleware {
	logger := log.With().Str("handlerName", "authMiddleware").Logger()
	return authMiddleware{
		responder: newResponder(logger),
	}
}

func (m authMiddleware) authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") {
			m.responder.writeError(w, errs.Unauthorized)
			return
		}

		userID := strings.TrimPrefix(authHeader, "Bearer ")
		if userID == "" {
			m.responder.writeError(w, errs.Unauthorized)
			return
		}

		ctx := r.Context()
		updatedCtx := ctxWithUserID(ctx, userID)
		updatedReq := r.WithContext(updatedCtx)
		next.ServeHTTP(w, updatedReq)
	})
}

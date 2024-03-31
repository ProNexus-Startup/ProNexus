package api

import (
	"encoding/json"
	"errors"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rs/zerolog"
	"net/http"
)

type responder struct {
	logger zerolog.Logger
}

func newResponder(logger zerolog.Logger) responder {
	return responder{logger}
}

func (r responder) writeJSON(w http.ResponseWriter, data any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	// json.NewEncoder will by default write a 200 status code
	// if encoding fails, an internal server error status code will be written instead
	if err := json.NewEncoder(w).Encode(data); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		r.logger.Error().Msgf("error encoding response: %s", err)

		if _, err := w.Write([]byte("Internal Server Error")); err != nil {
			r.logger.Error().Msgf("error sending internal server error response: %v", err)
		}
	}
}

func (r responder) writeError(w http.ResponseWriter, err error) {
	// check whether `err` is expected or nexpected
	// expected: the user sent a bad request or user request is not permitted according to our business logic
	// unexpected: our api server errored out unexpectedly and needs to be investigated

	// if `err` is expected, it will be of type `errs.ApiErr`
	var apiErr *errs.ApiErr
	// if `err` is not of type `errs.ApiErr`, this is an unexpected error
	if !errors.As(err, &apiErr) {
		// log detailed error
		r.logger.Error().Msg(err.Error())
		// respond to user with vague internal error. don't expose error details
		w.WriteHeader(http.StatusInternalServerError)
		r.writeJSON(w, "Internal Server Error")
		return
	}

	// if we're here, `err` is of type `errs.ApiErr`, which means it's an expected error
	w.WriteHeader(apiErr.StatusCode)
	r.writeJSON(w, apiErr.Error())
}

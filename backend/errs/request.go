package errs

import (
	"net/http"
)

var (
	Unauthorized = NewApiErr(http.StatusUnauthorized, "unauthorized")
)

func Malformed(payloadName string) *ApiErr {
	return NewApiErr(http.StatusBadRequest, payloadName+" malformed")
}

func BadRequest(message string) *ApiErr {
	return NewApiErr(http.StatusBadRequest, message)
}

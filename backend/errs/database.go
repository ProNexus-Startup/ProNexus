package errs

import (
	"errors"
	"fmt"
	"net/http"
)

var (
	ErrAlreadyExists = errors.New("already exists")
	ErrNotFound      = errors.New("not found")
)

func NewAlreadyExists(entity string) *ApiErr {
	return &ApiErr{http.StatusConflict, fmt.Errorf("%s %w", entity, ErrAlreadyExists)}
}

func NewNotFound(entity string) *ApiErr {
	return &ApiErr{http.StatusNotFound, fmt.Errorf("%s %w", entity, ErrNotFound)}
}

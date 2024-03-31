package errs

import (
	"errors"
)

type ApiErr struct {
	StatusCode int
	err        error
}

func NewApiErr(statusCode int, message string) *ApiErr {
	return &ApiErr{
		StatusCode: statusCode,
		err:        errors.New(message),
	}
}

// implements error interface. this allows us to pass an instance of ApiErr as an argument of type `error`
func (e *ApiErr) Error() string {
	return e.err.Error()
}

// this function allows us to do the following:
// err := &ApiErr{StatusCode: ..., err: someSentinelError}
// errors.Is(err, someSentinelError) ==> evaluates to true
func (e *ApiErr) Unwrap() error {
	return e.err
}

package api

import (
	"context"
	"errors"
)

type organizationIDKeyType string

const organizationIDKey organizationIDKeyType = "organizationID"

func ctxWithOrganizationID(ctx context.Context, organizationID string) context.Context {
	return context.WithValue(ctx, organizationIDKey, organizationID)
}

func ctxGetOrganizationID(ctx context.Context) (string, error) {
	if ctxOrganizationID := ctx.Value(organizationIDKey); ctxOrganizationID == nil {
		return "", errors.New("ctxGetOrganizationID: key not found in context")
	} else if organizationIDAsString, ok := ctxOrganizationID.(string); !ok {
		return "", errors.New("ctxGetOrganizationID: value for organization is not of type `organization`")
	} else {
		return organizationIDAsString, nil
	}
}

type userIDKeyType string

const userIDKey userIDKeyType = "userID"

// ctxWithUserID returns a new context with the given user ID included.
func ctxWithUserID(ctx context.Context, userID string) context.Context {
	return context.WithValue(ctx, userIDKey, userID)
}

// ctxGetUserID retrieves the user ID from the context, if available.
func ctxGetUserID(ctx context.Context) (string, error) {
	if ctxUserID := ctx.Value(userIDKey); ctxUserID == nil {
		return "", errors.New("ctxGetUserID: key not found in context")
	} else if userIDAsString, ok := ctxUserID.(string); !ok {
		return "", errors.New("ctxGetUserID: value for userID is not of type string")
	} else {
		return userIDAsString, nil
	}
}

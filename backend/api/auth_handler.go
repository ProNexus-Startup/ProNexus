package api

import (
    "os" // Ensure this is imported for accessing environment variables
    "encoding/json"
    "errors"
    "fmt"
    "github.com/rpupo63/ProNexus/backend/database"
    "github.com/rpupo63/ProNexus/backend/errs"
    "github.com/rpupo63/ProNexus/backend/models"
    "github.com/rs/zerolog"
    "github.com/rs/zerolog/log"
    "golang.org/x/crypto/bcrypt"
    "net/http"
    "github.com/google/uuid"
)

type authHandler struct {
    logger           zerolog.Logger
    responder        responder
    tokenSecret      string
    userRepo         database.UserRepo
    organizationRepo database.OrganizationRepo
}

// Corrected to not include tokenSecret as a parameter
func newAuthHandler(userRepo database.UserRepo, organizationRepo database.OrganizationRepo) authHandler {
    logger := log.With().Str("handlerName", "authHandler").Logger()
    tokenSecret := os.Getenv("TOKEN_SECRET") // Read the token secret from an environment variable

    return authHandler{
        logger:           logger,
        responder:        newResponder(logger),
        tokenSecret:      tokenSecret, // This now correctly uses the environment variable
        userRepo:         userRepo,
        organizationRepo: organizationRepo,
    }
}

/*
// Logout method implementation
func (h authHandler) logout() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization") // Adjust based on how you send the token
        if token == "" {
            h.responder.writeError(w, errs.BadRequest("missing token"))
            return
        }

        remainingValidity, err := getTokenRemainingValidity(token, h.tokenSecret)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error calculating token validity: %v", err))
            return
        }

        // Store the token in the blacklist with the remaining validity period as its expiration in the storage.
        err = h.tokenStore.StoreToken(token, remainingValidity)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error blacklisting token: %v", err))
            return
        }

        h.responder.writeJSON(w, map[string]string{"status": "success", "message": "logged out successfully"})
    }
}*/

type credentials struct {
	Email    string
	Password string
}

func (h authHandler) login() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var credentials credentials
        if err := json.NewDecoder(r.Body).Decode(&credentials); err != nil {
            h.responder.writeError(w, errs.Malformed("credentials"))
            return
        }

        // Find user by email
        userFromDB, err := h.userRepo.FindByEmail(credentials.Email)
        if errors.Is(err, errs.ErrNotFound) {
            h.responder.writeError(w, errs.Unauthorized)
            return
        } else if err != nil {
            h.responder.writeError(w, fmt.Errorf("error getting user from user repo: %v", err))
            return
        }

        // Compare hashed password with the one provided
        if err := bcrypt.CompareHashAndPassword([]byte(userFromDB.Password), []byte(credentials.Password)); err != nil {
            h.responder.writeError(w, errs.Unauthorized)
            return
        }

        var accessToken string

        // Check if user already has a valid token
        accessToken, err = newAccess(userFromDB)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("auth_handler.login: Error generating access JWT: %v", err))
            return
        }

        // Prepare the response
        response := struct {
            Token string `json:"token"`
        }{
            Token: accessToken,
        }

        // Send the response back to the client
        h.responder.writeJSON(w, response)
    }
}

func (h authHandler) signup() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var newUserRequest struct {
            models.User
        }   

        if err := json.NewDecoder(r.Body).Decode(&newUserRequest); err != nil {
            h.responder.writeError(w, errs.Malformed("request body"))
            return
        }

        if newUserRequest.FullName == "" || newUserRequest.Email == "" || newUserRequest.Password == "" {
            h.responder.writeError(w, errs.BadRequest("fullname, email, and password are required"))
            return
        }

        _, err := h.userRepo.FindByEmail(newUserRequest.Email)
        if err == nil {
            h.responder.writeError(w, errs.NewAlreadyExists("user"))
            return
        } else if !errors.Is(err, errs.ErrNotFound) {
            h.responder.writeError(w, fmt.Errorf("error checking user existence: %v", err))
            return
        }

        if newUserRequest.OrganizationID != "" {
            _, err := h.organizationRepo.FindByID(newUserRequest.OrganizationID)
            if err != nil {
                h.responder.writeError(w, errs.NewNotFound("organization"))
                return
            }
        }

        passwordHash, err := bcrypt.GenerateFromPassword([]byte(newUserRequest.Password), bcrypt.DefaultCost)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error generating password hash: %v", err))
            return
        }

        newUser := newUserRequest.User
        newUser.ID = uuid.NewString()
        newUser.Password = string(passwordHash)
        newUser.OrganizationID = string(newUserRequest.OrganizationID)

        // Generate JWT for the new user
        jwtToken, err := newAccess(newUser)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error generating JWT: %v", err))
            // Optionally, handle the failure of JWT generation differently
            return
        }

        newUser.Token = string(jwtToken)

        if err := h.userRepo.Insert(newUser); err != nil {
            h.responder.writeError(w, fmt.Errorf("error creating new user: %v", err))
            return
        }

        // Respond with JWT token
        h.responder.writeJSON(w, map[string]string{
            "status": "success",
            "message": "user created successfully",
            "token": jwtToken, // Include the JWT token in the response
        })
    }
}
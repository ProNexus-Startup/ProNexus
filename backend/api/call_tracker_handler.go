package api

import (
	"encoding/json"
	"fmt"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"net/http"
	"strings"
    "time"
)

type callTrackerHandler struct {
	responder     		responder
	logger         		zerolog.Logger
	callTrackerRepo		database.CallTrackerRepo
    availableExpertRepo database.AvailableExpertRepo
    userRepo            database.UserRepo
}

func newCallTrackerHandler(callTrackerRepo database.CallTrackerRepo, userRepo database.UserRepo, availableExpertRepo database.AvailableExpertRepo) callTrackerHandler {
	logger := log.With().Str("handlerName", "callTrackerHandler").Logger()

	return callTrackerHandler{
		responder:      	 newResponder(logger),
		logger:        		 logger,
		callTrackerRepo: 	 callTrackerRepo,
        availableExpertRepo: availableExpertRepo,
        userRepo:            userRepo,
	}
}

func (h callTrackerHandler) makeCallTracker() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        log.Printf("Starting makeCallTracker handler")

        // Extracting the email from the Authorization header
        authHeader := r.Header.Get("Authorization")
        log.Printf("Authorization header: %s", authHeader)
        if authHeader == "" {
            h.responder.writeError(w, fmt.Errorf("No authorization header provided"))
            log.Printf("No authorization header provided")
            return
        }
        
        // Ensure the token starts with "Bearer "
        if !strings.HasPrefix(authHeader, "Bearer ") {
            h.responder.writeError(w, fmt.Errorf("Authorization header must start with 'Bearer '"))
            log.Printf("Authorization header does not start with 'Bearer '")
            return
        }

        emailAuth := strings.TrimPrefix(authHeader, "Bearer ")
        log.Printf("Token and email part: %s", emailAuth)

        // Ensure that the emailAuth is at least 36 characters to avoid out of range error
        if len(emailAuth) < 36 {
            h.responder.writeError(w, fmt.Errorf("Authorization token is too short"))
            log.Printf("Authorization token is too short")
            return
        }

        token := emailAuth[:36]
        log.Printf("Extracted token: %s", token)
        if token != "eb756c9b-4eb8-4442-a94c-a3bae5b76b0b" {
            h.responder.writeError(w, fmt.Errorf("Token not authenticated for auth access"))
            log.Printf("Token not authenticated for auth access")
            return
        }

        email := emailAuth[36:]
        log.Printf("Extracted email: %s", email)
        user, err := h.userRepo.FindByEmail(email)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("Error retrieving user: %v", err))
            log.Printf("Error retrieving user: %v", err)
            return
        }
        log.Printf("User found: %s", user.Email)

        // Decode the request body to get the AvailableExpertID, MeetingStartDate, and MeetingEndDate
        var requestBody struct {
            AvailableExpertID string    `json:"availableExpertId"`
            MeetingStartDate  time.Time `json:"meetingStartDate"`
            MeetingEndDate    time.Time `json:"meetingEndDate"`
        }
        if err := json.NewDecoder(r.Body).Decode(&requestBody); err != nil {
            h.responder.writeError(w, fmt.Errorf("Malformed request body: %v", err))
            log.Printf("Malformed request body: %v", err)
            return
        }
        log.Printf("Request body decoded: %+v", requestBody)

        // Retrieve the AvailableExpert from the repository
        availableExpert, err := h.availableExpertRepo.FindByID(requestBody.AvailableExpertID)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("Error retrieving available expert: %v", err))
            log.Printf("Error retrieving available expert: %v", err)
            return
        }
        log.Printf("Available expert found: %+v", availableExpert)

        // Create a new CallTracker entry based on the AvailableExpert entry
        newCallTracker := models.CallTracker{
            ID:                availableExpert.ID,
            Name:              availableExpert.Name,
            OrganizationID:    availableExpert.OrganizationID,
            ProjectID:         availableExpert.ProjectID,
            Favorite:          availableExpert.Favorite,
            Profession:        availableExpert.Profession,
            Company:           availableExpert.Company,
            CompanyType:       availableExpert.CompanyType,
            StartDate:         availableExpert.StartDate,
            Description:       availableExpert.Description,
            Geography:         availableExpert.Geography,
            Angle:             availableExpert.Angle,
            Status:            "Scheduled",
            AIAssessment:      availableExpert.AIAssessment,
            AIAnalysis:        availableExpert.AIAnalysis,
            Comments:          availableExpert.Comments,
            Availabilities:    availableExpert.Availabilities,
            ExpertNetworkName: availableExpert.ExpertNetworkName,
            Cost:              availableExpert.Cost,
            ScreeningQuestionsAndAnswers: availableExpert.ScreeningQuestionsAndAnswers,
            EmploymentHistory: availableExpert.EmploymentHistory,
            AddedExpertBy:     availableExpert.AddedExpertBy,
            DateAddedExpert:   availableExpert.DateAddedExpert,
            Trends:            availableExpert.Trends,
            AddedCallBy:       user.Email, // Set the AddedCallBy to the email of the user making the call
            DateAddedCall:     time.Now(), // Set the current time as DateAddedCall
            InviteSent:        false,      // Default value for InviteSent
            MeetingStartDate:  requestBody.MeetingStartDate, // Use the provided MeetingStartDate
            MeetingEndDate:    requestBody.MeetingEndDate,   // Use the provided MeetingEndDate
            PaidStatus:        false,      // Default value for PaidStatus
            Rating:            0,          // Default value for Rating
            LinkedInLink:      availableExpert.LinkedInLink,
        }
        log.Printf("New call tracker entry created: %+v", newCallTracker)

        // Insert the new CallTracker entry into the repository
        if err := h.callTrackerRepo.Insert(newCallTracker); err != nil {
            h.responder.writeError(w, fmt.Errorf("Error inserting new call tracker: %v", err))
            log.Printf("Error inserting new call tracker: %v", err)
            return
        }
        log.Printf("New call tracker entry inserted")

        // Call the deleteAvailableExpert method to delete the corresponding AvailableExpert entry
        if err := h.availableExpertRepo.Delete(availableExpert.ID); err != nil {
            h.responder.writeError(w, fmt.Errorf("Error deleting available expert: %v", err))
            log.Printf("Error deleting available expert: %v", err)
            return
        }
        log.Printf("Available expert entry deleted")

        h.responder.writeJSON(w, map[string]string{
            "status":  "success",
            "message": "New call tracker entry created and available expert entry deleted successfully",
        })
        log.Printf("Response sent with success message")
    }
}

func (h callTrackerHandler) deleteCallTracker() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        token = strings.TrimPrefix(token, "Bearer ")

        // Now passing the token and the tokenSecret to validateToken
        _, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
		callTrackerID := r.URL.Query().Get("ID")
		if callTrackerID == "" {
			h.responder.writeError(w, fmt.Errorf("ID is required"))
			return
		}

		if err := h.callTrackerRepo.Delete(callTrackerID); err != nil {
			h.responder.writeError(w, fmt.Errorf("error deleting tracked call: %v", err))
			return
		}

		h.responder.writeJSON(w, "Tracked call deleted successfully")
	}
}

func (h callTrackerHandler) getAllCallTrackers() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            h.responder.writeError(w, fmt.Errorf("no Authorization header provided"))
            return
        }

        token = strings.TrimPrefix(token, "Bearer ")

        // Now passing the token and the tokenSecret to validateToken
        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("invalid token: %v", err))
            return
        }
        
        var callTrackers []models.CallTracker
        callTrackers, err = h.callTrackerRepo.FindByOrganization(user.OrganizationID)

        if err != nil {
            h.responder.writeError(w, fmt.Errorf("error fetching call trackers: %v", err))
            return
        }

        h.responder.writeJSON(w, callTrackers)
    }
}

func (h callTrackerHandler) manuallyMakeCallTracker() http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            h.responder.writeError(w, fmt.Errorf("No authorization header provided"))
            return
        }
        
        // Ensure the token starts with "Bearer "
        if !strings.HasPrefix(authHeader, "Bearer ") {
            h.responder.writeError(w, fmt.Errorf("Authorization header must start with 'Bearer '"))
            return
        }

        token := strings.TrimPrefix(authHeader, "Bearer ")

        user, err := validateToken(token)
        if err != nil {
            h.responder.writeError(w, fmt.Errorf("Error retrieving user: %v", err))
            return
        }
        log.Printf("User found: %s", user.Email)

        var callTracker models.CallTracker
        if err := json.NewDecoder(r.Body).Decode(&callTracker); err != nil {
            h.responder.writeError(w, fmt.Errorf("Malformed call tracker details: %v", err))
            return
        }

        if err := h.callTrackerRepo.Insert(callTracker); err != nil {
            h.responder.writeError(w, fmt.Errorf("Error inserting call tracker: %v", err))
            return
        }

		h.responder.writeJSON(w, "call tracker made successfully")

    }
}
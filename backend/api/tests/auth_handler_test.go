package api

import (
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/errs"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rpupo63/ProNexus/backend/testdata/samplego"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"net/http"
	"net/http/httptest"
	"testing"
)

type authHandlerSuite struct {
	suite.Suite
	testServer        *httptest.Server
	database          database.Database
	existingUserEmail string
}

func TestAuthHandler(t *testing.T) {
	suite.Run(t, new(authHandlerSuite))
}

func (suite *authHandlerSuite) SetupSuite() {
	// test data ids: these are set in ../testdata/samplepsql/000002_init.up.sql
	suite.existingUserEmail = "pupo@example.com"
}

func (suite *authHandlerSuite) TearDownSuite() {
	suite.testServer.Close()
}

func (suite *authHandlerSuite) SetupTest() {
	// if using mock db, initialize brand new instance of database that can be used for duration of test
	// also initialize new instance of server that will use that database for that test
	suite.database = samplego.NewDB()
	suite.testServer = httptest.NewServer(newRouter(suite.database))
}

func (suite *authHandlerSuite) Test_LoginExistingUser_ReturnsUser() {
	// send request to login existing user
	userResponse, err := sendReq[credentials, models.User]("POST", suite.testServer.URL+"/login", "", &credentials{Email: suite.existingUserEmail})// Password: "notapassword"})
	require.NoError(suite.T(), err, "did not expect error sending request to login a user")

	// check that user was returned
	require.Equal(suite.T(), suite.existingUserEmail, userResponse.Email)
}

func (suite *authHandlerSuite) Test_LoginNonExistingUser_ReturnsUnauthorized() {
	// send request to login non existing user
	_, err := sendReq[credentials, models.User]("POST", suite.testServer.URL+"/login", "", &credentials{Email: "userthatdoesnotexist@gmail.com"})
	require.ErrorIs(suite.T(), err, errs.Unauthorized, "expected error from logging in to be of errs.Unauthorized")
}

func (suite *authHandlerSuite) Test_SignupNonExistingUserAndLogin_CorrectCredentials_Works() {
    // Test data
    desiredUserEmail := "newuser@example.com"
    desiredUserPassword := "securepassword" // Assuming you're now handling passwords
    desiredOrganizationID := "default-organization-id" // Example organization ID
    
    // Send request to signup a user with organization information and password
    desiredUser := models.User{
        FullName:       "New User",
        Email:          desiredUserEmail,
        Password:       desiredUserPassword, // This should be the plaintext password for the signup process
        OrganizationID: desiredOrganizationID, // Include if your signup process requires it
    }
    _, err := sendReq[models.User, string]("POST", suite.testServer.URL+"/signup", "", &desiredUser)
    require.NoError(suite.T(), err, "did not expect error sending request to signup a user")

    // Try to sign-in user
    credentials := struct {
        Email    string `json:"email"`
        Password string `json:"password"` // Make sure to send the password for login
    }{
        Email:    desiredUserEmail,
        Password: desiredUserPassword,
    }
    responseUser, err := sendReq[struct{ Email, Password string }, models.User]("POST", suite.testServer.URL+"/login", "", &credentials)
    require.NoError(suite.T(), err, "did not expect error sending request to login user")
    require.NotEmpty(suite.T(), responseUser.ID)
    require.Equal(suite.T(), desiredUserEmail, responseUser.Email)
    // The response should ideally not include the password or token for security reasons; adjust your API response accordingly.
    require.NotEmpty(suite.T(), responseUser.Token, "The user should have a valid token after login")
}


func (suite *authHandlerSuite) Test_SignupNonExistingUserAndLogin_WrongCredentials_Fails() {
	func (suite *authHandlerSuite) Test_SignupNonExistingUserAndLogin_WrongCredentials_Fails() {
		// Test data
		desiredUserEmail := "newuser@example.com"
		desiredUserPassword := "correctpassword"
		wrongPassword := "wrongpassword"
	
		// Assuming a structure similar to the signup test that includes a password
		desiredUser := struct {
			models.User
			Password string `json:"password"`
		}{
			User: models.User{
				FullName: "New User",
				Email:    desiredUserEmail,
			},
			Password: desiredUserPassword,
		}
	
		// Send request to signup a user
		_, err := sendReq[struct{ models.User; Password string }, string]("POST", suite.testServer.URL+"/signup", "", &desiredUser)
		require.NoError(suite.T(), err, "did not expect error sending request to signup a user")
	
		// Try to sign-in user with wrong password
		_, err = sendReq[credentials, models.User]("POST", suite.testServer.URL+"/login", "", &credentials{
			Email:    desiredUserEmail,
			Password: wrongPassword,
		})
		require.ErrorIs(suite.T(), err, errs.Unauthorized, "expected error from logging in to be of errs.Unauthorized")
	}
}

func (suite *authHandlerSuite) Test_SignupExistingEmail() {
	// Test data, including a password this time
	existingUser := struct {
		models.User
		Password string `json:"password"`
	}{
		User: models.User{
			FullName: "Existing User",
			Email:    suite.existingUserEmail,
		},
		Password: "password",
	}

	// Send request to signup a user with an already existing email
	_, err := sendReq[struct{ models.User; Password string }, string]("POST", suite.testServer.URL+"/signup", "", &existingUser)

	// Parse request
	var apiErr *errs.ApiErr
	require.ErrorAs(suite.T(), err, &apiErr, "expected error of already exists when sending request to signup a user")
	require.Equal(suite.T(), http.StatusConflict, apiErr.StatusCode, "expected status code to be 409")
}
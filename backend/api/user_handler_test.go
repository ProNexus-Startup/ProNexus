package api

import (
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/rpupo63/ProNexus/backend/models"
	"github.com/rpupo63/ProNexus/backend/testdata/samplego"
	"github.com/stretchr/testify/require"
	"github.com/stretchr/testify/suite"
	"net/http/httptest"
	"testing"
	"time"
)

type userHandlerSuite struct {
	suite.Suite
	testServer *httptest.Server
	database   database.Database
	userID     string
}

func TestUserHandler(t *testing.T) {
	suite.Run(t, new(userHandlerSuite))
}

func (suite *userHandlerSuite) SetupSuite() {
	// test data ids: these are set in ../testdata/
	suite.userID = "e1b7a095-154f-4e86-b0df-3735fb870758"
}

func (suite *userHandlerSuite) TearDownSuite() {
	suite.testServer.Close()
}

func (suite *userHandlerSuite) SetupTest() {
	suite.database = samplego.NewDB()
	suite.testServer = httptest.NewServer(newRouter(suite.database))
}

func (suite *userHandlerSuite) Test_RecordSignature_AddsSignature() {
	// get our test user from database
	userStart, err := suite.database.UserRepo().FindByEmail(models.User{ID: suite.userID})
	require.NoError(suite.T(), err, "did not expect error sending request to get start user events of user")

	// check that user has no signature
	require.Zero(suite.T(), userStart.SignedAt, "expected userStart.signedAt to be zero value of its type")

	// send request to assign an existing user to our user
	timeNow := time.Now()
	_, err = sendReq[SignatureEvent, string]("POST", suite.testServer.URL+"/signature", suite.userID, &SignatureEvent{Date: timeNow})
	require.NoError(suite.T(), err, "did not expect error sending request to add a user to a user")

	// get user after
	userEnd, err := suite.database.UserRepo().FindByEmail(models.User{ID: suite.userID})
	require.NoError(suite.T(), err, "did not expect error sending request to get start user events of user")

	// check that user now has signature
	require.NotZero(suite.T(), userEnd.SignedAt, "did not expect userEnd.SignedAt to be zero value of its type")
	require.True(suite.T(), userEnd.SignedAt.Equal(timeNow))
}

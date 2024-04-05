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

type availableExpertHandlerSuite struct {
	suite.Suite
	testServer *httptest.Server
	database   database.Database
	organizationID     string
}

func TestAvailableExpertHandler(t *testing.T) {
	suite.Run(t, new(availableExpertSuite))
}

func (suite *availableExpertHandlerSuite) SetupSuite() {
	// test data ids: these are set in ../testdata/samplepsql/000002_init.up.sql
	suite.organizationID = "e1b7a095-154f-4e86-b0df-3735fb870758"
}

func (suite *availableExpertHandlerSuite) TearDownSuite() {
	suite.testServer.Close()
}

func (suite *availableExpertHandlerSuite) SetupTest() {
	suite.database = samplego.NewDB()
	suite.testServer = httptest.NewServer(newRouter(suite.database))
}

func (suite *availableExpertHandlerSuite) Test_RecordAvailableExpert_AddsAvailableExpert() {
	// get availableExpert events now
	availableExpertStart, err := suite.database.AvailableExpertRepo().SelectAll()
	require.NoError(suite.T(), err, "did not expect error sending request to get start call tracker events of organization")

	// check that organization has one availableExpert
	require.Len(suite.T(), availableExpertStart, 1, "expected only one organization call tracker")

	// send request to assign an existing availableExpert to our organization
	newAvailableExpert := []*models.AvailableExpert{{AvailableExpertID: 4, Date: time.Now()}, {AvailableExpertID: 5}}

	for i, event := range newAvailableExpert {
		_, err = sendReq[models.AvailableExpert, string]("POST", suite.testServer.URL+"/experts", suite.organizationID, event)
		require.NoError(suite.T(), err, "did not expect error sending request to add a availableExpert to a organization. failed in iteration %d", i)
	}

	// get availableExpert events after
	availableExpertEnd, err := suite.database.AvailableExpertRepo().SelectAll()
	require.NoError(suite.T(), err, "did not expect error sending request to get end availableExpert events of organization")

	// check that organization now has two new call trackers
	require.Len(suite.T(), availableExpertEnd, len(availableExpertStart)+len(newAvailableExpert), "expected two call trackers")
}

func (suite *availableExpertHandlerSuite) Test_DeleteAvailableExpert_RemovesAvailableExpert() {
	// Step 1: Add an availableExpert to set up the test environment.
	initialAvailableExpert := &models.AvailableExpert{
		AvailableExpertID: "some-unique-id", // Make sure this ID is unique.
		Date:              time.Now(),
	}
	_, err := suite.database.AvailableExpertRepo().Insert(suite.organizationID, *initialAvailableExpert)
	require.NoError(suite.T(), err, "did not expect error when adding availableExpert")

	// Verify the expert has been added.
	expertsBeforeDeletion, err := suite.database.AvailableExpertRepo().SelectAll()
	require.NoError(suite.T(), err)
	require.Len(suite.T(), expertsBeforeDeletion, 1, "expected one availableExpert before deletion")

	// Step 2: Send request to delete the availableExpert.
	_, err = sendReq[string, string]("DELETE", suite.testServer.URL+"/experts?expertID="+initialAvailableExpert.AvailableExpertID, suite.organizationID, "")
	require.NoError(suite.T(), err, "did not expect error sending request to delete availableExpert")

	// Step 3: Verify the expert has been removed.
	expertsAfterDeletion, err := suite.database.AvailableExpertRepo().SelectAll()
	require.NoError(suite.T(), err)
	require.Len(suite.T(), expertsAfterDeletion, 0, "expected no availableExperts after deletion")
}

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

type callTrackerHandlerSuite struct {
	suite.Suite
	testServer *httptest.Server
	database   database.Database
	organizationID     string
}

func TestCallTrackerHandler(t *testing.T) {
	suite.Run(t, new(callTrackerSuite))
}

func (suite *callTrackerHandlerSuite) SetupSuite() {
	// test data ids: these are set in ../testdata/samplepsql/000002_init.up.sql
	suite.organizationID = "e1b7a095-154f-4e86-b0df-3735fb870758"
}

func (suite *callTrackerHandlerSuite) TearDownSuite() {
	suite.testServer.Close()
}

func (suite *callTrackerHandlerSuite) SetupTest() {
	suite.database = samplego.NewDB()
	suite.testServer = httptest.NewServer(newRouter(suite.database))
}

func (suite *callTrackerHandlerSuite) Test_RecordCallTracker_AddsCallTracker() {
	// get callTracker events now
	callTrackerStart, err := suite.database.CallTrackerRepo().SelectAll()
	require.NoError(suite.T(), err, "did not expect error sending request to get start call tracker events of organization")

	// check that organization has one callTracker
	require.Len(suite.T(), callTrackerStart, 1, "expected only one organization call tracker")

	// send request to assign an existing callTracker to our organization
	newCallTracker := []*models.CallTracker{{CallTrackerID: 4, Date: time.Now()}, {CallTrackerID: 5}}

	for i, event := range newCallTracker {
		_, err = sendReq[models.CallTracker, string]("POST", suite.testServer.URL+"/calls", suite.organizationID, event)
		require.NoError(suite.T(), err, "did not expect error sending request to add a callTracker to a organization. failed in iteration %d", i)
	}

	// get callTracker events after
	callTrackerEnd, err := suite.database.CallTrackerRepo().SelectAll()
	require.NoError(suite.T(), err, "did not expect error sending request to get end callTracker events of organization")

	// check that organization now has two new call trackers
	require.Len(suite.T(), callTrackerEnd, len(callTrackerStart)+len(newCallTracker), "expected two call trackers")
}

func (suite *callTrackerHandlerSuite) Test_DeleteCallTracker_RemovesCallTracker() {
    // Step 1: Add a callTracker to set up the test scenario.
    initialCallTracker := &models.CallTracker{
        CallTrackerID: "some-unique-id", // Ensure this ID is unique.
        Date:          time.Now(),
    }
    _, err := suite.database.CallTrackerRepo().Insert(suite.organizationID, *initialCallTracker)
    require.NoError(suite.T(), err, "did not expect error when adding callTracker")

    // Verify the call tracker has been added.
    trackersBeforeDeletion, err := suite.database.CallTrackerRepo().SelectAll()
    require.NoError(suite.T(), err)
    require.Len(suite.T(), trackersBeforeDeletion, 1, "expected one callTracker before deletion")

    // Step 2: Send request to delete the callTracker.
    _, err = sendReq[string, string]("DELETE", suite.testServer.URL+"/calls?callTrackerID="+initialCallTracker.CallTrackerID, suite.organizationID, "")
    require.NoError(suite.T(), err, "did not expect error sending request to delete callTracker")

    // Step 3: Verify the call tracker has been removed.
    trackersAfterDeletion, err := suite.database.CallTrackerRepo().SelectAll()
    require.NoError(suite.T(), err)
    require.Len(suite.T(), trackersAfterDeletion, 0, "expected no callTrackers after deletion")
}

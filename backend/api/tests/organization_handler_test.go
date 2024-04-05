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

type organizationHandlerSuite struct {
	suite.Suite
	testServer *httptest.Server
	database   database.Database
	organizationID     string
}

func TestOrganizationHandler(t *testing.T) {
	suite.Run(t, new(organizationHandlerSuite))
}

func (suite *organizationHandlerSuite) SetupSuite() {
	// test data ids: these are set in ../testdata/
	suite.organizationID = "e1b7a095-154f-4e86-b0df-3735fb870758"
}

func (suite *organizationHandlerSuite) TearDownSuite() {
	suite.testServer.Close()
}

func (suite *organizationHandlerSuite) SetupTest() {
	suite.database = samplego.NewDB()
	suite.testServer = httptest.NewServer(newRouter(suite.database))
}
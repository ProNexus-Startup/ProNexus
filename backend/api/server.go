package api

import (
	"context"
	"fmt"
	"net/http"
	"time"
	"github.com/rpupo63/ProNexus/backend/config"
	"github.com/rpupo63/ProNexus/backend/database"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/cors"
	"github.com/rs/zerolog/log"
)

type Server struct {
	*http.Server
}

func NewServer(database database.Database) (Server, error) {
	c := config.New()
	router := newRouter(database, withConfig(c))

	server := &http.Server{
		Addr:    ":" + config.GetString(c, "PORT", "8080"),
		Handler: router,
	}

	return Server{server}, nil
}

type router struct {
	config map[string]string
}

func withConfig(c map[string]string) func(*router) {
	return func(r *router) {
		r.config = c
	}
}

func newRouter(database database.Database, opts ...func(*router)) *chi.Mux {
	var router router
	for _, opt := range opts {
		opt(&router)
	}

	chiRouter := chi.NewRouter()
	// middlewares
	//corsAllowedOrigin := config.GetString(router.config, "CORSALLOWEDORIGIN", "http://*")
	//frontendURL := "https://pronexus-73107.firebaseapp.com"
	chiRouter.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"}, //AllowedOrigins:   []string{frontendURL, "http://localhost:8080"}, //[]string{corsAllowedOrigin},
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowCredentials: true,
		AllowedHeaders:   []string{"Content-Type", "Authorization", "userID"},
		MaxAge:           config.GetInt(router.config, "MAXAGE", 300),
	}))

	// define handlers
	authMiddleware := newAuthMiddleware()
	organizationHandler := newOrganizationHandler(database.OrganizationRepo(), database.UserRepo(), database.CallTrackerRepo(), database.AvailableExpertRepo(), database.ProjectRepo())
	userHandler := newUserHandler(database.UserRepo(), database.AvailableExpertRepo(), database.CallTrackerRepo())
	authHandler := newAuthHandler(database.UserRepo(), database.OrganizationRepo())//, config.GetString(router.config, "TOKENSECRET", "tokenSecret"))
	AvailableExpertHandler := newAvailableExpertHandler(database.AvailableExpertRepo(), database.UserRepo())
    CallTrackerHandler := newCallTrackerHandler(database.CallTrackerRepo(), database.UserRepo(), database.AvailableExpertRepo())
	ProjectHandler := newProjectHandler(database.ProjectRepo(), database.UserRepo())

	// index
	chiRouter.Handle("/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "hello world")
	}))

	chiRouter.Group(func(r chi.Router) {
		r.Post("/login", authHandler.login())
		r.Post("/signup", authHandler.signup())
		r.Post("/refresh", authHandler.refresh())
		r.Post("/makeorg", organizationHandler.makeOrg())
		r.Get("/users", userHandler.getUsers())
		//r.Post("/logout", authHandler.logout())
	})

	// user endpoints
	chiRouter.Group(func(r chi.Router) {
		r.Use(authMiddleware.authenticate)
		r.Get("/me", userHandler.getMe())
		r.Get("/users", organizationHandler.getUsers())
		r.Post("/update-user-project", userHandler.changeProjects())
		r.Get("/expert-list", AvailableExpertHandler.getAllAvailableExperts())
		r.Get("/experts", AvailableExpertHandler.getExpertsByUserEmail())
		r.Post("/make-expert", AvailableExpertHandler.makeAvailableExpert())
		r.Post("/manually-make-expert", AvailableExpertHandler.manuallyMakeAvailableExpert())
		r.Get("/calls-list", CallTrackerHandler.getAllCallTrackers())
		r.Post("/make-call", CallTrackerHandler.makeCallTracker())
		r.Post("/manually-make-call", CallTrackerHandler.manuallyMakeCallTracker())
		r.Get("/projects-list", ProjectHandler.getAllProjects())
		r.Get("/angles", ProjectHandler.getAnglesByUserEmail())
		r.Post("/make-project", ProjectHandler.makeProject())
		r.Post("/update-project", ProjectHandler.updateProject())
		r.Post("/signature", userHandler.makeSignature())
		r.Delete("/experts/{expertID}", AvailableExpertHandler.deleteAvailableExpert())
		r.Delete("/calls/{callTrackerID}", CallTrackerHandler.deleteCallTracker())
		r.Delete("/projects/{projectID}", ProjectHandler.deleteProject())
	})

	return chiRouter
}

func (s Server) Start(errChannel chan<- error) {
	log.Info().Msgf("Server started on: %s", s.Addr)
	errChannel <- s.ListenAndServe()
}

func (s Server) ShutdownGracefully(timeout time.Duration) {
	log.Info().Msg("Gracefully shutting down...")

	gracefullCtx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	if err := s.Shutdown(gracefullCtx); err != nil {
		log.Error().Msgf("Error shutting down the server: %v", err)
	} else {
		log.Info().Msg("HttpServer gracefully shut down")
	}
}
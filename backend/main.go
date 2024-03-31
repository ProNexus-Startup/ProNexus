package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
	"github.com/rpupo63/ProNexus/backend/api"
	"github.com/rpupo63/ProNexus/backend/testdata/samplego"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func main() {
	// logging setup
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Info().Msg("Initializing app...")

	// initialize database, panic if we cannot
	database := samplego.NewDB()

	// initialize error channel
	errChannel := make(chan error)
	defer close(errChannel)

	// initialize and start server
	server, err := api.NewServer(database)
	if err != nil {
		log.Fatal().Msgf("error initializing server: %v", err)
	}
	go server.Start(errChannel)

	// listen to signal interrupt
	go listenToInterrupt(errChannel)

	fatalErr := <-errChannel
	log.Info().Msgf("Closing server: %v", fatalErr)

	server.ShutdownGracefully(30 * time.Second)
}

func listenToInterrupt(errChannel chan<- error) {
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
	errChannel <- fmt.Errorf("%s", <-c)
}

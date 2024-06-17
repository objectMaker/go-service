package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"go.uber.org/automaxprocs/maxprocs"
)

var ARG_ENV string

func main() {

	if _, err := maxprocs.Set(); err != nil {
		fmt.Println("maxprocs: %w", err)
		os.Exit(1)
	}

	core := runtime.GOMAXPROCS(0)
	log.Printf("starting server, env is %s, core is %d", ARG_ENV, core)
	defer log.Println("server ended")
	sd := make(chan os.Signal, 1)
	signal.Notify(sd, syscall.SIGINT, syscall.SIGTERM)
	<-sd
}

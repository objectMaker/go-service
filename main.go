package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
)

var ARG_ENV string

func main() {
	log.Println("starting server...")
	defer log.Println("server ended")
	sd := make(chan os.Signal, 1)
	signal.Notify(sd, syscall.SIGINT, syscall.SIGTERM)
	<-sd
}

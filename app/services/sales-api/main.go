package main

import (
	"fmt"
	"log"
	"os"
	"runtime"

	"go.uber.org/automaxprocs/maxprocs"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

var ARG_ENV string
var Logger *zap.SugaredLogger

func main() {
	fmt.Println(ARG_ENV)

}

func init() {
	initMaxprocs()
	initLogger("sales-api")

}

func initMaxprocs() {

	if _, err := maxprocs.Set(); err != nil {
		fmt.Println("maxprocs: %w", err)
		os.Exit(1)
	}

	core := runtime.GOMAXPROCS(0)
	log.Printf("starting server, env is %s, core is %d", ARG_ENV, core)

}

func initLogger(serviceName string) {
	config := zap.NewProductionConfig()
	config.OutputPaths = []string{"stdout"}
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	config.DisableStacktrace = true
	config.InitialFields = map[string]interface{}{"service": serviceName}
	log, err := config.Build()
	if err != nil {
		fmt.Println("init logger failed", err)
		os.Exit(1)
	}
	Logger = log.Sugar()
	Logger.Info("init logger success")
}

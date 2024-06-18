package main

import (
	"errors"
	"fmt"
	"log"
	"os"
	"runtime"

	"github.com/ardanlabs/conf/v2"
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
	initConfig()

}

func initMaxprocs() {

	if _, err := maxprocs.Set(); err != nil {
		fmt.Println("maxprocs: %w", err)
		os.Exit(1)
	}

	core := runtime.GOMAXPROCS(0)
	log.Printf("starting server, env is %s, core is %d", ARG_ENV, core)

}

func initConfig() {
	cfg := struct {
		conf.Version
		Web struct {
			Port string `conf:"default:0.0.0.0:3000"`
		}
	}{
		Version: conf.Version{
			Build: ARG_ENV,
			Desc:  "Sales API' Describes",
		},
	}
	const prefix = "SALES"
	help, err := conf.Parse(prefix, &cfg)
	if err != nil {
		if errors.Is(err, conf.ErrHelpWanted) {
			fmt.Println(help)
		}
		fmt.Println(fmt.Errorf("parsing config: %w", err))
		os.Exit(1)
	}

	out, err := conf.String(&cfg)
	if err != nil {
		Logger.Fatal("init config failed:", err)
	}
	Logger.Infow("start read config: ", "output", out)
	defer Logger.Infow("initConfig finished")
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

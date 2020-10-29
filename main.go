// Copyright (c) 2020 IoTeX
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/iotexproject/prophecy/dispatcher"
	"github.com/iotexproject/prophecy/monitor"
)

const (
	pullInterval  = 5 * time.Second
	iotexMainnet  = "api.iotex.one:443"
	iotexContract = "io1pcg2ja9krrhujpazswgz77ss46xgt88afqlk6y"
)

type Stopper interface {
	Stop() error
}

func main() {
	// monitor the pebble registration contract
	monitor, err := monitor.NewIotexMonitor(true, iotexMainnet, iotexContract)
	if err != nil {
		log.Fatal("failed to create iotext monitor")
	}
	if err := monitor.Start(); err != nil {
		log.Fatal(err)
	}

	// start runner to poll the contract
	runner, err := dispatcher.NewRunner(pullInterval, monitor.Poll)
	if err != nil {
		log.Fatal(err)
	}
	if err := runner.Start(); err != nil {
		log.Fatal(err)
	}

	handleShutdown(monitor, runner)
}

func handleShutdown(service ...Stopper) {
	sig := make(chan os.Signal)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)

	for _ = range sig {
		log.Println("shutting down ...")
		for _, s := range service {
			if err := s.Stop(); err != nil {
				log.Fatal(err)
			}
		}
		return
	}
}

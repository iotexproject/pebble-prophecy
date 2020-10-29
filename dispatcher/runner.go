// Copyright (c) 2020 IoTeX
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

package dispatcher

import (
	"errors"
	"log"
	"sync"
	"time"
)

var (
	ErrNegTime    = errors.New("wait time cannot be negative")
	ErrNilHandler = errors.New("handler cannot be nil")
)

type (
	// RunFunc is the handler to run
	RunFunc func() error

	// runner implements the Runner interface
	runner struct {
		sync.WaitGroup
		start   chan struct{} // signal to start
		quit    chan struct{} // signal to quit
		ticker  *time.Ticker  // wait time before run next round
		timeout *time.Timer
		run     RunFunc
	}
)

func NewRunnerWithDeadline(wait, duration time.Duration, run RunFunc) (*runner, error) {
	return newRunner(wait, duration, run)
}

func NewRunner(wait time.Duration, run RunFunc) (*runner, error) {
	return newRunner(wait, 0, run)
}

func newRunner(wait, duration time.Duration, run RunFunc) (*runner, error) {
	if wait < 0 || duration < 0 {
		return nil, ErrNegTime
	}
	if run == nil {
		return nil, ErrNilHandler
	}
	r := runner{
		start:  make(chan struct{}),
		quit:   make(chan struct{}),
		ticker: time.NewTicker(wait),
		run:    run,
	}

	if duration > 0 {
		r.timeout = time.NewTimer(duration)
	} else {
		// stop the timer so it does not fire
		r.timeout = time.NewTimer(time.Second)
		r.timeout.Stop()
	}

	r.Add(1)
	go func() {
		<-r.start
		for {
			select {
			case <-r.quit:
				r.Done()
				return
			case <-r.timeout.C:
				r.Done()
				return
			case <-r.ticker.C:
				// run the runner
				if err := r.run(); err != nil {
					log.Println(err)
				}
			}
		}
	}()
	return &r, nil
}

// Start starts the runner
func (r *runner) Start() error {
	r.start <- struct{}{}
	return nil
}

// Stop signals the runner to quit
func (r *runner) Stop() error {
	r.timeout.Stop()
	r.ticker.Stop()
	close(r.quit)
	r.Wait()
	return nil
}

// Copyright (c) 2020 IoTeX
// This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
// warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
// permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
// License 2.0 that can be found in the LICENSE file.

package monitor

import (
	"context"
	"crypto/tls"
	"sync"

	"google.golang.org/grpc"
	"google.golang.org/grpc/connectivity"
	"google.golang.org/grpc/credentials"

	"github.com/iotexproject/iotex-proto/golang/iotexapi"
)

type iotexMonitor struct {
	sync.RWMutex
	secureConn   bool
	endpoint     string
	contractAddr string
	grpcConn     *grpc.ClientConn
	api          iotexapi.APIServiceClient
	stream       iotexapi.APIService_StreamLogsClient
	filter       *iotexapi.LogsFilter
}

func NewIotexMonitor(secureConn bool, endpoint, contractAddr string) (*iotexMonitor, error) {
	return &iotexMonitor{
		secureConn:   secureConn,
		endpoint:     endpoint,
		contractAddr: contractAddr,
	}, nil
}

func (im *iotexMonitor) Start() error {
	// make gRPC connection
	return im.connect()
}

func (im *iotexMonitor) Stop() error {
	return im.grpcConn.Close()
}

func (im *iotexMonitor) connect() error {
	im.Lock()
	defer im.Unlock()
	// Check if the existing connection is good.
	if im.grpcConn != nil && im.grpcConn.GetState() != connectivity.Shutdown {
		return nil
	}

	var (
		opts []grpc.DialOption
		err  error
	)
	if im.secureConn {
		opts = append(opts, grpc.WithTransportCredentials(credentials.NewTLS(&tls.Config{})))
	} else {
		opts = append(opts, grpc.WithInsecure())
	}
	im.grpcConn, err = grpc.Dial(im.endpoint, opts...)
	if err != nil {
		return err
	}

	// call stream log API to listen on contract
	im.api = iotexapi.NewAPIServiceClient(im.grpcConn)
	im.stream, err = im.api.StreamLogs(context.Background(), &iotexapi.StreamLogsRequest{
		Filter: &iotexapi.LogsFilter{
			Address: []string{im.contractAddr},
		},
	})
	return err
}

func (im *iotexMonitor) Poll() error {
	// check new events from contract
	_, err := im.stream.Recv()
	if err != nil {
		return err
	}

	// TODO: create new feeder task
	return nil
}

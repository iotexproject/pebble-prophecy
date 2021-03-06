########################################################################################################################
# Copyright (c) 2019 IoTeX
# This is an alpha (internal) release and is not suitable for production. This source code is provided 'as is' and no
# warranties are given as to title or non-infringement, merchantability or fitness for purpose and, to the extent
# permitted by law, all liability for your use of the code is disclaimed. This source code is governed by Apache
# License 2.0 that can be found in the LICENSE file.
########################################################################################################################

# Go parameters
GOCMD=go
GOLINT=golint
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
BUILD_TARGET=prophecy

# Pkgs
ALL_PKGS := $(shell go list ./... )
PKGS := $(shell go list ./... | grep -v /vendor/ )

# Docker parameters
DOCKERCMD=docker

# Package Info
PACKAGE_VERSION := $(shell git describe --tags --always)
PACKAGE_COMMIT_ID := $(shell git rev-parse HEAD)
GIT_STATUS := $(shell git status --porcelain)
ifdef GIT_STATUS
	GIT_STATUS := "dirty"
else
	GIT_STATUS := "clean"
endif
GO_VERSION := $(shell go version)
BUILD_TIME=$(shell date +%F-%Z/%T)
VersionImportPath := github.com/iotexproject/iotex-antenna/version
PackageFlags += -X '$(VersionImportPath).PackageVersion=$(PACKAGE_VERSION)'
PackageFlags += -X '$(VersionImportPath).PackageCommitID=$(PACKAGE_COMMIT_ID)'
PackageFlags += -X '$(VersionImportPath).GitStatus=$(GIT_STATUS)'
PackageFlags += -X '$(VersionImportPath).GoVersion=$(GO_VERSION)'
PackageFlags += -X '$(VersionImportPath).BuildTime=$(BUILD_TIME)'
PackageFlags += -s -w

V ?= 0
ifeq ($(V),0)
	ECHO_V = @
else
	VERBOSITY_FLAG = -v
	DEBUG_FLAG = -debug
endif

all: clean test

.PHONY: build
build:
	$(GOBUILD) -o ./$(BUILD_TARGET) -v ./main.go

.PHONY: fmt
fmt:
	$(GOCMD) fmt ./...

.PHONY: test
test: fmt
	$(GOTEST) ./... -v -short -race

.PHONY: lint
lint:
	@echo "Installing golint..."
	go get golang.org/x/lint/golint
	go list ./... | grep -v /vendor/ | xargs $(GOLINT)

.PHONY: clean
clean:
	@echo "Cleaning..."
	$(ECHO_V)rm -f ./$(BUILD_TARGET)
	$(ECHO_V)$(GOCLEAN) -i $(PKGS)
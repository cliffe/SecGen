BIN = maze
DIR = ./cmd/maze
GOROOT ?= /usr/local/go

all: clean test build

build: deps
	go build -o build/$(BIN) $(DIR)

install: deps
	go install ./...

deps:
	go get -u github.com/golang/dep/cmd/dep
	dep ensure

cross: crossdeps
	goxz -os=linux,darwin,freebsd,netbsd,windows -arch=386,amd64 -n $(BIN) $(DIR)

crossdeps: deps
	go get github.com/Songmu/goxz/cmd/goxz

test: testdeps build
	go test -v $(DIR)...

testdeps:
	go get -d -v -t ./...

lint: lintdeps build
	go vet
	golint -set_exit_status $(go list ./... | grep -v /vendor/)

lintdeps:
	go get -d -v -t ./...
	go get -u github.com/golang/lint/golint

clean:
	rm -rf build goxz
	go clean

.PHONY: build install deps cross crossdeps test testdeps lint lintdeps clean

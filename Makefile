SHELL := /bin/sh

# tool prefers the pinned binary of `make tools` in ./bin/ over the PATH.
tool = $(or $(wildcard $(CURDIR)/bin/$(1)),$(1))
GOLANGCI_LINT := $(call tool,golangci-lint)

# The steps of check run in order, also under make -j.
.NOTPARALLEL:

.PHONY: check fmt vet lint tidy test build deps tools snapshot

# check runs every step, fast to slow, and stops at the first failure.
check: fmt vet lint tidy test build deps

fmt:
	@echo '==> gofmt -l .'
	@out=$$(gofmt -l .) || { printf '%s\n' "$$out"; exit 1; }; \
	if [ -n "$$out" ]; then \
		printf '%s\n' "$$out"; \
		echo 'gofmt: the files above are not formatted'; \
		exit 1; \
	fi

vet:
	@echo '==> go vet ./...'
	@go vet ./...

lint:
	@echo '==> golangci-lint run'
	@$(GOLANGCI_LINT) run

tidy:
	@echo '==> go mod tidy -diff'
	@go mod tidy -diff

test:
	@echo '==> go test -race ./...'
	@go test -race ./...

build:
	@echo '==> go build -o /dev/null ./...'
	@go build -o /dev/null ./...

deps:
	@echo '==> dependency check'
	@sh scripts/check-deps.sh

tools:
	@sh scripts/install-tools.sh bin

# snapshot builds the release locally into dist/ and publishes nothing.
snapshot:
	@$(call tool,goreleaser) release --snapshot --clean

SHELL := /bin/sh

# tool prefers the pinned binary of `make tools` in bin/ over the PATH.
# The path stays relative, so a checkout path with a space still works.
tool = $(or $(wildcard bin/$(1)),$(1))
GOLANGCI_LINT := $(call tool,golangci-lint)

# The steps of check run in order, also under make -j.
.NOTPARALLEL:

.PHONY: check fmt vet lint tidy test build deps tools snapshot

# check runs every step, fast to slow, and stops at the first failure.
# vet, lint, and deps run once per release target (scripts/each-target.sh).
check: fmt vet lint tidy test build deps

# fmt checks the .go files of every build tag in the folders that ./...
# walks: it skips folders whose name starts with . or _, testdata, and
# bin/ and dist/, and files whose name starts with . or _.
fmt:
	@echo '==> gofmt -l (the .go files that ./... walks)'
	@out=$$(find . \( -type d \( -name '.?*' -o -name '_*' -o -name testdata \
		-o -path ./bin -o -path ./dist \) -prune \) -o \
		\( -type f -name '*.go' ! -name '.*' ! -name '_*' \
		-exec gofmt -l {} + \)) || { printf '%s\n' "$$out"; exit 1; }; \
	if [ -n "$$out" ]; then \
		printf '%s\n' "$$out"; \
		echo 'gofmt: the files above are not formatted'; \
		exit 1; \
	fi

vet:
	@echo '==> go vet ./... (each release target)'
	@sh scripts/each-target.sh go vet ./...

lint:
	@echo '==> golangci-lint run (each release target)'
	@sh scripts/each-target.sh $(GOLANGCI_LINT) run

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
	@echo '==> dependency check (each release target)'
	@sh scripts/each-target.sh sh scripts/check-deps.sh

tools:
	@sh scripts/install-tools.sh

# snapshot builds the release locally into dist/ and publishes nothing.
snapshot:
	@$(call tool,goreleaser) release --snapshot --clean

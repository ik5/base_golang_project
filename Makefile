now:=$(shell date +'%Y-%m-%d_%T')
git_ver:=$(shell git rev-parse HEAD)
git_branch:=$(shell git branch | grep -E '^\*' | cut -f2 -d' ')

linters:
	echo "check for struct memory alignment:"
	aligo check ./...

	echo "lint code based on .golangci.yml"
	golangci-lint run ./...

deps:
	go mod tidy

install-linters:
	go install github.com/essentialkaos/aligo/v2@latest
	go install github.com/nametake/golangci-lint-langserver@latest
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

generate-output-dir:
	mkdir -p bin

build-dev: generate-output-dir; deps; linters;
	cd <path>; go build -v \
		-ldflags="-linkmode external -extldflags -static -X main.gitVersion=${git_ver} -X main.buildTime=${now} -X main.gitBranch=${git_branch}"\
		-race -trimpath \
		-o ../../bin/<name>

build-release: generate-output-dir; deps; linters;
	cd <path>; go build -v \
		-ldflags="-s -w -linkmode external -extldflags -static -X main.gitVersion=${git_ver} -X main.buildTime=${now} -X main.gitBranch=${git_branch}"\
		-trimpath \
		-o ../../bin/<name>

clean-build:
	rm -f bin/<name>

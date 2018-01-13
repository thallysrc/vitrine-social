.PHONY: all
all: build

# set default as dev if not set
export VITRINESOCIAL_ENV ?= dev
export DATABASE_HOST ?= 0.0.0.0
export m ?= default

.PHONY: build

install: ## install project dependences
	go get github.com/rubenv/sql-migrate/...
	go get -u github.com/golang/dep/cmd/dep
	cd server; dep ensure

new-migration: ## create a new migration, use make new-migration m=message to set the message
	sql-migrate new -config=./devops/dbconfig.yml -env=production "$(m)"

migrations: ## run pending migrations
	docker-compose up -d
	go get github.com/rubenv/sql-migrate/...
	sql-migrate up -config=devops/dbconfig.yml -env=production

serve: ## start server
	docker-compose up -d
	cd server && go run main.go

serve-watch: ## start server with hot reload
	docker-compose up -d
	go get github.com/codegangsta/gin
	gin --port 8081 --appPort 8000 --path ${PWD}/server --bin server-cmd run server/main.go

postgres-cmd: ## open the postgresql command line
	docker-compose exec postgres psql -h $$DATABASE_HOST -U postgres vitrine

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
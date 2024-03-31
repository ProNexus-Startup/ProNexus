DATABASE_URL = postgresql://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable

# Migrations
.PHONY: migrate_up
migrate_up:
	migrate -path database/migrations -database $(DATABASE_URL) -verbose up

.PHONY: migrate_up_step
migrate_up_step:
	migrate -path database/migrations -database $(DATABASE_URL) -verbose up 1

.PHONY: migrate_down
migrate_down:
	migrate -path database/migrations -database $(DATABASE_URL) -verbose down

.PHONY: migrate_down_step
migrate_down_step:
	migrate -path database/migrations -database $(DATABASE_URL) -verbose down 1

.PHONY: migrate_force_version
migrate_force_version:
	migrate -path database/migrations -database $(DATABASE_URL) -verbose force $(version)

.PHONY: migrate_create
migrate_create:
	migrate create -ext sql -dir migrations -seq $(name)

.PHONY: migrate_version
migrate_version:
	migrate -path database/migrations -database $(DATABASE_URL) version

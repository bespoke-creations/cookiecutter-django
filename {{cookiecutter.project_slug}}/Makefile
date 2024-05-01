SHELL := /bin/bash

init:  ## Initialize the project
	@if [ ! -d "$$HOME/.virtualenvs/{{cookiecutter.project_slug}}-py3.12.2" ]; then \
		echo "Install virtualenvwrapper and 'mkvirtualenv {{cookiecutter.project_slug}}-py3.12,2'"; \
		exit 1; \
	fi
	@test -d .git || git init
	@test ! -f .env-local && cp .envs/env-local .env-local || true
	@test ! -f .env-test && cp .envs/env-test .env-test || true
	@test ! -f .env-docker && cp .envs/env-docker .env-docker || true
	@mkdir -p tmp
	@pre-commit install
	pip install --no-cache-dir -U pip -U setuptools -U wheel
	pip install --no-cache-dir -Ur requirements/local.txt

start:
	docker compose up -d

migrate:
	docker compose run --rm django python manage.py reset_db --noinput --close-sessions
	docker compose run --rm django python manage.py migrate
	docker compose run --rm django python manage.py loaddata initial_data
	docker compose run --rm django python manage.py collectstatic --noinput

stop:  ## Does not remove volumes, so `make start` will re-use the existing database (e.g., migrations)
	@docker compose down

restart:  ## Restart the project from scratch -- requires migrations to be run again
	docker compose down --volumes
	docker compose up -d postgres redis
	@make migrate
	docker compose up -d
	@echo "Ready - run `make open`"

make open:  ## Open the project in the browser
	open http://{{cookiecutter.project_slug}}.test:18010/admin/

test:
	python -m black .
	bandit -q -c pyproject.toml -r {{cookiecutter.project_slug}}
	djlint --reformat {{cookiecutter.project_slug}}
	ruff check {{cookiecutter.project_slug}}
	docker compose build django
	docker compose run --rm django tox -v --develop --workdir tmp/.tox-docker 2>&1 | tee tmp/tox.log

build:
	@docker compose build django

rebuild:
	@docker compose build --no-cache django

ssh:
	@docker exec -it {{cookiecutter.project_slug}}_local_django bash

shell:
	@docker compose run --rm django python manage.py shell

dbshell:
	@docker exec -it {{cookiecutter.project_slug}}-be-postgres-1 psql -U root {{cookiecutter.project_slug}}

translations:
	@docker compose run --rm django python manage.py makemessages --all --ignore node_modules --ignore venv
	@docker compose run --rm django python manage.py makemessages -d djangojs --all --ignore node_modules --ignore venv
	@docker compose run --rm django python manage.py compilemessages

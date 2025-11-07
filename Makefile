# Makefile для управления Docker Compose проектом
# Использование: make <цель> [PROFILE=dev|prod]

PROFILE ?= dev
ENV_FILE := .env.$(PROFILE)  # .env.dev или .env.prod

COMPOSE := docker compose --profile $(PROFILE) --env-file $(ENV_FILE)
EXEC := $(COMPOSE) exec frankenphp

# Для console: извлекаем аргументы (всё кроме "console")
COMMAND_ARGS := $(filter-out console,$(MAKECMDGOALS))

.PHONY: help up down logs exec build ps clean composer-install composer-update console

help:
	@echo "Доступные цели:"
	@echo "  up       - Запуск сервисов в фоне"
	@echo "  down     - Остановка сервисов"
	@echo "  logs     - Просмотр логов всех сервисов (с -f)"
	@echo "  logs-<service> - Логи конкретного сервиса (напр. logs-angie)"
	@echo "  exec     - Вход в shell FrankenPHP"
	@echo "  build    - Перестроить образы"
	@echo "  ps       - Статус сервисов"
	@echo "  clean    - Остановка и очистка volumes"
	@echo "  composer-install - Установка пакетов Composer (с опциями для dev/prod)"
	@echo "  composer-update  - Обновление пакетов Composer"
	@echo "  console          - Выполнение Symfony console команды (передайте как аргумент, напр. make console cache:clear)"
	@echo "PROFILE=prod - Для продакшена"
up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

logs-%:
	$(COMPOSE) logs -f $*

exec:
	$(COMPOSE) exec frankenphp sh

build:
	$(COMPOSE) build --no-cache

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down -v

composer-install:
	$(EXEC) composer install $(if $(filter prod,$(PROFILE)),--no-dev --optimize-autoloader)

composer-update:
	$(EXEC) composer update $(if $(filter prod,$(PROFILE)),--no-dev --optimize-autoloader)

console:
	@if [ -z "$(COMMAND_ARGS)" ]; then \
		echo "Укажите команду, напр. make console cache:clear"; \
	else \
		$(EXEC) php bin/console $(COMMAND_ARGS); \
	fi

%::
@: # Подавление вывода для несуществующих целей (чтобы не ругался make)

# --- ПЕРЕМЕННЫЕ ---
# Основные файлы Docker Compose
COMPOSE_FILES = -f docker-compose.yaml -f docker-compose.franken.yaml
# Основной профиль, который нужен всегда (Backend: PHP, DB)
CORE_PROFILE = frankenphp
# Профиль для запуска вместе с прокси сервером Anige
PROXY_PROFILE = angie
# Имя основного PHP-сервиса (контейнера)
PHP_SERVICE = frankenphp

all: up
# --- ЦЕЛИ ЗАПУСКА СЕРВИСОВ (UP) ---
# 1. Запуск основных сервисов (Backend: DB, FrankenPHP)
.PHONY: up
up:
	@echo "🚀 Запуск только Backend-сервисов (FrankenPHP + Redis + PostgreSQL + Mercure)..."
	docker compose $(COMPOSE_FILES) --profile $(CORE_PROFILE) up -d


# 2. Запуск сервисов с прокси сервером (Backend + Anige)
.PHONY: up-with-proxy
up-full:
	@echo "🚀 Запуск всех сервисов (Angie + FrankenPHP + Redis + PostgreSQL + Mercure)..."
	docker compose $(COMPOSE_FILES) --profile $(CORE_PROFILE) --profile $(PROXY_PROFILE) up -d


# 3. Добавление нового пакета Composer (например: make composer-require package=symfony/mailer)
.PHONY: composer-require
composer-require:
	@echo "➕ Добавление пакета $(package)..."
	docker compose $(COMPOSE_FILES) exec $(PHP_SERVICE) composer require $(package)

# 4. Запуск любой произвольной консольной команды (например: make console-exec command="make:entity Post")
.PHONY: console
console:
	@echo "⚡️ Выполнение команды: $(command)..."
	docker compose $(COMPOSE_FILES) exec $(PHP_SERVICE) php bin/console $(command)

# 5. Очистка кеша Symfony
.PHONY: symfony-cache-clear
symfony-cache-clear:
	@echo "🧹 Очистка кеша Symfony..."
	docker compose $(COMPOSE_FILES) exec $(PHP_SERVICE) php bin/console cache:clear

# 6. Запуск миграций Doctrine
.PHONY: migrate
migrate:
	@echo "⚙️ Запуск миграций Doctrine..."
	docker compose $(COMPOSE_FILES) exec $(PHP_SERVICE) php bin/console doctrine:migrations:migrate --no-interaction

# 7. Запуск Symfony Var-Dumper Server на хосте (для получения вывода dump())
.PHONY: dump-server
dump-server:
	@echo "👂 Запуск Symfony Dumper Server (Ctrl+C для остановки)..."
	docker compose $(COMPOSE_FILES) exec $(PHP_SERVICE) php bin/console server:dump

# 8. Проверка логов FrankenPHP (для отладки)
.PHONY: logs-franken
logs-franken:
	@echo "📝 Логи FrankenPHP..."
	docker compose $(COMPOSE_FILES) --profile $(CORE_PROFILE) logs -f $(PHP_SERVICE)

# 11. Остановка всех запущенных контейнеров
.PHONY: down
down:
	@echo "🛑 Остановка и удаление контейнеров..."
	docker compose $(COMPOSE_FILES) down

.PHONY: help
help:
	@echo "--------------------------------------------------------"
	@echo "   Управление Docker Compose и Symfony (Make Targets)"
	@echo "--------------------------------------------------------"
	@echo "--- ЗАПУСК (UP/DOWN) ---"
	@echo "up    - Запуск только Backend-сервисов (FrankenPHP + Redis + PostgreSQL + Mercure)."
	@echo "up-full       - Запуск всех сервисов (Anige + FrankenPHP + Redis + PostgreSQL + Mercure)."
	@echo "down          - Остановка и удаление контейнеров."
	@echo ""
	@echo "--- COMPOSER ---"
	@echo "composer-require - Добавление пакета. Использование: make composer-require package=symfony/mailer"
	@echo ""
	@echo "--- SYMFONY CONSOLE ---"
	@echo "symfony-cache-clear - Очистка кеша."
	@echo "migrate  - Запуск миграций Doctrine."
	@echo "console      - Произвольная команда. Использование: make console command=\"doctrine:schema:update --force\""
	@echo ""
	@echo "--- ОТЛАДКА ---"
	@echo "dump-server   - Запуск Symfony Dumper Server (локально)."
	@echo "logs-franken  - Просмотр логов FrankenPHP."
	@echo "help          - Показать эту помощь."
	@echo "--------------------------------------------------------"
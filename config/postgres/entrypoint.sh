#!/bin/bash
set -e  # Остановка при ошибке

# Проверяем, задана ли переменная для read_db
if [ -z "$POSTGRES_READ_DB" ]; then
  echo "Error: POSTGRES_READ_DB environment variable is not set!"
  exit 1
fi

# Ждём готовности Postgres
while ! pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

# Подключаемся и создаём вторую БД
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Устанавливаем наш пароль
    ALTER USER "$POSTGRES_USER" WITH PASSWORD '$POSTGRES_PASSWORD';
    -- Создаём вторую базу данных из переменной POSTGRES_READ_DB
    CREATE DATABASE "$POSTGRES_READ_DB";

    -- Опционально: создаём роль для чтения (только SELECT в read_db)
    -- CREATE ROLE elkk_reader WITH LOGIN PASSWORD 'readerpassword' NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
    -- GRANT CONNECT ON DATABASE "$POSTGRES_READ_DB" TO elkk_reader;
    -- GRANT USAGE ON SCHEMA public TO elkk_reader;
    -- GRANT SELECT ON ALL TABLES IN SCHEMA public TO elkk_reader;

    -- Выводим подтверждение
    SELECT 'Databases created: ' || '$POSTGRES_DB' || ' (write) and ' || '$POSTGRES_READ_DB' || ' (read)' AS message;
EOSQL

echo "Initialization complete! Write DB: $POSTGRES_DB, Read DB: $POSTGRES_READ_DB"
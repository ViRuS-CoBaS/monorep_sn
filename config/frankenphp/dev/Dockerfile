# 1. Базовый образ
# Используем образ с инструментами для разработчика (8.3-dev или 8.4-dev)
FROM dunglas/frankenphp:8.4-dev 

# 2. Установка PCNTL
# PCNTL (Process Control) необходим для работы воркеров Symfony Messenger.
# 
# apk add --no-cache: устанавливает зависимости для Alpine Linux (база FrankenPHP)
# libc-dev: обычно необходим для компиляции расширений
RUN apk add --no-cache libc-dev \
    # Установка расширения pcntl
    && docker-php-ext-install pcntl \
    # Очистка: удаляем временные зависимости, чтобы сохранить размер образа
    && apk del libc-dev


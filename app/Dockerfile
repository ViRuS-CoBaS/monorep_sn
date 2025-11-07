 # По умолчанию dev; в prod: --build-arg APP_ENV=prod
ARG APP_ENV=dev
FROM dunglas/frankenphp:php8.4 AS base

# удобные переменные
ENV APP_ENV=dev \
    APP_DEBUG=1 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp/composer
# системные зависимости + xdebug для дебага
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libpq-dev libicu-dev libzip-dev \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-install pdo pdo_pgsql intl zip opcache pcntl\
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Копируем зависимости Symfony (без app/ — context ./app)
COPY composer.json composer.lock ./
RUN --mount=type=cache,target=/root/.composer/cache/ \
    composer install \
    ${APP_ENV:+--no-dev --optimize-autoloader --no-scripts} \
    --no-interaction

# Копируем код Symfony (COPY . . — весь context)
COPY . .

# Установка скриптов (если нужно)
RUN composer run-script post-install-cmd || true

# Права
RUN chown -R www-data:www-data ./var/

EXPOSE 80

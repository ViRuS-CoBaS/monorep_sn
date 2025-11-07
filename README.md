x# Описание проекта

## Обзор
Этот проект представляет собой стек для развертывания Symfony-приложения с использованием Docker Compose. Основные компоненты:
- **Angie**: Веб-сервер (форк Nginx) для обработки HTTP/HTTPS-запросов с поддержкой HTTP/3 (QUIC). Работает как reverse proxy, перенаправляя трафик на FrankenPHP.
- **FrankenPHP**: PHP-рантайм на базе Caddy, интегрированный с Symfony для обработки динамического контента. Поддерживает hot-reload в dev-режиме.
- **Postgres**: База данных (версия 16) для хранения данных приложения.
- **Redis**: Кэш-сервер для сессий и кэширования.

Проект поддерживает два профиля: `dev` (с hot-reload) и `prod` (без hot-reload для производительности). Зависимости: Angie зависит от FrankenPHP, FrankenPHP — от Postgres и Redis. Логи сохраняются в `./logs`, конфиги — в `./config`.

## Архитектура
- **Сеть**: `my-stack-network` (bridge) для внутренней коммуникации.
- **Volumes**: Персистентные данные для Postgres (`postgres_data`) и Redis (`redis_data`).
- **Порты**: HTTP — 8080, HTTPS/HTTP3 — 8443.
- **Переменные окружения**: Используются `.env` (например, `APP_ENV`, `DB_PASSWORD`).

Проект подходит для локальной разработки и продакшена Symfony с фокусом на производительность и безопасность.

# Команды для управления проектом

Все команды выполняются в корневой директории проекта (где лежит `docker-compose.yaml`). Рекомендуется использовать профили: `--profile dev` для разработки или `--profile prod` для продакшена.

### Запуск
- Запуск в фоновом режиме (detached):  
  `docker compose --profile dev up -d`  
  (Или замените `dev` на `prod` для продакшена.)
- Полный запуск с выводом логов:  
  `docker compose --profile dev up`

### Остановка
- Остановка сервисов:  
  `docker compose --profile dev down`
- Остановка с удалением volumes (осторожно, потеря данных):  
  `docker compose --profile dev down -v`

### Проверка логов
- Логи всех сервисов:  
  `docker compose --profile dev logs -f` (следить в реальном времени с `-f`)
- Логи конкретного сервиса:  
  `docker compose --profile dev logs -f angie` (или `frankenphp`, `postgres`, `redis`)

### Исполнение команд
- Войти в контейнер и запустить shell:  
  `docker compose --profile dev exec frankenphp sh` (или другой сервис, напр. `postgres psql -U symfony`)
- Выполнить команду без входа:  
  `docker compose --profile dev exec frankenphp php bin/console cache:clear`  
  (Пример для Symfony-команд в FrankenPHP.)

### Дополнительно
- Перестроить образы:  
  `docker compose --profile dev build --no-cache`
- Проверка статуса:  
  `docker compose --profile dev ps`


## Статический анализ и рефакторинг

В проекте используются инструменты для автоматизации проверки и улучшения качества кода: **PHPStan** для статического анализа (находит ошибки до выполнения) и **Rector** для рефакторинга (автоматически обновляет код под современные стандарты Symfony 7.3). Оба — dev-зависимости, не попадают в продакшен.

### Статический анализ (PHPStan)
PHPStan анализирует код на несоответствия типам, деприкейшены, потенциальные баги и Symfony-специфику (DI, роутинг, Doctrine). Уровень строгости: 8 (максимум для Symfony 7.3).

#### Конфигурация
- Файл: `phpstan.neon` (в корне проекта).
- Пути: `src/` (и опционально `tests/`).
- Расширения: Symfony и Doctrine (если используется).

#### Скрипты Composer
| Скрипт              | Команда                          | Описание |
|---------------------|----------------------------------|----------|
| `composer phpstan`  | `phpstan analyse --level=8`      | Полный анализ кода. Выводит ошибки/OK. |
| `composer phpstan:fix` | `phpstan analyse --level=8 --error-format=raw` | Анализ в сыром формате (для CI). |

**Использование**:
- Запуск: `composer phpstan` — перед коммитом.
- Если ошибок много, снижайте уровень (`--level=5`) и постепенно повышайте.

### Рефакторинг (Rector)
Rector автоматически мигрирует код: обновляет деприкейшены, атрибуты роутинга, сериализацию и улучшает стиль под Symfony 7.3. Использует `withComposerBased(symfony: true)` для авто-определения версий.

#### Конфигурация
- Файл: `rector.php` (в корне проекта).
- Пути: `src/` и `tests/`.
- Правила: Автоматические для PHP 8.2+ и Symfony 7.3 (миграции, качество кода).

#### Скрипты Composer
| Скрипт                  | Команда                                | Описание |
|-------------------------|----------------------------------------|----------|
| `composer rector`       | `rector process src --dry-run --clear-cache` | Тестовый запуск: показывает diff без изменений. |
| `composer rector:fix`   | `rector process src`                   | Применяет рефакторинг к `src/`. |
| `composer rector:fix:tests` | `rector process tests`             | Рефакторинг только тестов. |
| `composer rector:cache-clear` | `rector process src --clear-cache` | Очистка кэша и анализ. |

**Использование**:
1. `composer rector` — проверьте изменения.
2. `composer rector:fix` — примените (на чистом репозитории).
3. Для больших проектов: Запускайте по директориям, чтобы избежать конфликтов.

### Полная проверка качества
| Скрипт          | Команда                  | Описание |
|-----------------|--------------------------|----------|
| `composer quality` | `@phpstan` + `@rector` | Запускает PHPStan и Rector (dry-run). Для pre-commit или CI. |

## Настройка Symfony Web Debug Toolbar для работы за прокси (например, в Docker)

Если вы работаете с Symfony в контейнере (Docker) или за прокси-сервером с HTTPS-терминацией, Web Debug Toolbar (WDT) может некорректно отображаться: стили и ассеты загружаются по HTTP, что приводит к ошибкам mixed content в браузере.

### Проблема
Symfony по умолчанию не распознаёт реальный протокол (HTTPS) и генерирует ссылки на ресурсы toolbar по HTTP. Это блокируется современными браузерами для безопасности.

### Решение
Добавьте IP-адрес вашего внутреннего прокси/контейнера в настройку `trusted_proxies` в файле `config/packages/framework.yaml`. Это позволит Symfony доверять заголовкам прокси (например, `X-Forwarded-Proto: https`) и генерировать правильные HTTPS-ссылки.

#### Пример конфигурации
```yaml
framework:
    trusted_proxies: ['127.0.0.1/8', '::1', '172.17.0.1']  # Замените '172.17.0.1' на IP вашего контейнера/прокси
    trusted_headers: ['x-forwarded-for', 'x-forwarded-host', 'x-forwarded-proto', 'x-forwarded-port']
```

- **Как найти IP контейнера?** Выполните `docker inspect <container_id> | grep IPAddress` или `ip addr show` внутри контейнера.
- Для динамики используйте переменные окружения: в `.env` добавьте `TRUSTED_PROXIES=127.0.0.1/8,::1,172.17.0.1`, а в YAML — `trusted_proxies: '%env(TRUSTED_PROXIES)%'`.

### После изменений
1. Очистите кэш: `php bin/console cache:clear --env=dev`.
2. Перезапустите сервер (или контейнер).
3. Проверьте в браузере: стили `/_wdt/styles` должны загружаться по HTTPS без ошибок в Console.

Это обеспечит стабильную работу toolbar в dev-окружении. В production toolbar обычно отключён (`APP_DEBUG=0`), так что настройка не критична. Если проблема persists, проверьте логи в `var/log/dev.log`.
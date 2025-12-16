# PostgreSQL Template

Шаблон для быстрого запуска PostgreSQL с pgAdmin.

## Быстрый старт

```bash
# Скопируйте пример переменных окружения
cp .env.example .env

# При необходимости отредактируйте .env файл
# Запустите сервисы
docker-compose up -d

# Проверьте статус
docker-compose ps
```

## Сервисы

- **PostgreSQL 15.8** (Alpine)
  - Порт: `5432` (настраивается через `POSTGRES_PORT`)
  - Данные сохраняются в volume `postgres_data`

- **pgAdmin 4**
  - Порт: `5050` (настраивается через `PGADMIN_PORT`)
  - URL: http://localhost:5050

## Инициализация БД

SQL скрипты из `initdb-scripts/` автоматически выполняются при первом запуске. Добавьте свои скрипты с префиксом номера (например, `02-create-tables.sql`).

## Полезные команды

```bash
# Подключение к БД
docker exec -it postgres-dev psql -U postgres -d postgres

# Бэкап БД
docker exec postgres-dev pg_dump -U postgres postgres > backup.sql

# Остановка
docker-compose down
```


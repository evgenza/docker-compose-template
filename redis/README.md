# Redis Template

Шаблон для быстрого запуска Redis с веб-интерфейсом Redis Commander.

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

- **Redis 7.2** (Alpine)
  - Порт: `6379` (настраивается через `REDIS_PORT`)
  - Данные сохраняются в volume `redis_data`
  - AOF (Append Only File) включен для персистентности

- **Redis Commander** — веб-интерфейс для управления Redis
  - Порт: `8081` (настраивается через `REDIS_COMMANDER_PORT`)
  - URL: http://localhost:8081

## Полезные команды

```bash
# Подключение к Redis CLI
docker exec -it redis-dev redis-cli

# Подключение с паролем (если установлен)
docker exec -it redis-dev redis-cli -a ${REDIS_PASSWORD}

# Проверка статуса
docker exec -it redis-dev redis-cli ping

# Получить все ключи
docker exec -it redis-dev redis-cli KEYS "*"

# Установить значение
docker exec -it redis-dev redis-cli SET mykey "myvalue"

# Получить значение
docker exec -it redis-dev redis-cli GET mykey

# Остановка
docker-compose down
```

## Примеры использования

### Node.js

```javascript
const redis = require('redis');
const client = redis.createClient({
  host: 'localhost',
  port: 6379,
  password: process.env.REDIS_PASSWORD
});
```

### Python

```python
import redis
r = redis.Redis(
    host='localhost',
    port=6379,
    password=os.getenv('REDIS_PASSWORD')
)
```

### Go

```go
import "github.com/redis/go-redis/v9"

rdb := redis.NewClient(&redis.Options{
    Addr:     "localhost:6379",
    Password: os.Getenv("REDIS_PASSWORD"),
})
```


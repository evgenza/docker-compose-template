# MongoDB Template

Шаблон для быстрого запуска MongoDB с веб-интерфейсом Mongo Express.

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

- **MongoDB 7.0** — NoSQL база данных
  - Порт: `27017` (настраивается через `MONGODB_PORT`)
  - Данные сохраняются в volume `mongodb_data`
  - Root пользователь создается автоматически

- **Mongo Express** — веб-интерфейс для управления MongoDB
  - Порт: `8081` (настраивается через `MONGO_EXPRESS_PORT`)
  - URL: http://localhost:8081

## Инициализация БД

JavaScript скрипты из `initdb-scripts/` автоматически выполняются при первом запуске контейнера. Добавьте свои скрипты с префиксом номера (например, `02-create-user.js`).

## Полезные команды

```bash
# Подключение к MongoDB shell
docker exec -it mongodb-dev mongosh -u admin -p admin

# Подключение к конкретной БД
docker exec -it mongodb-dev mongosh -u admin -p admin --authenticationDatabase admin

# Выполнить JavaScript файл
docker exec -i mongodb-dev mongosh -u admin -p admin < script.js

# Бэкап БД
docker exec mongodb-dev mongodump --username admin --password admin --authenticationDatabase admin --out /backup

# Восстановление из бэкапа
docker exec mongodb-dev mongorestore --username admin --password admin --authenticationDatabase admin /backup

# Остановка
docker-compose down
```

## Примеры использования

### Node.js (Mongoose)

```javascript
const mongoose = require('mongoose');
mongoose.connect('mongodb://admin:admin@localhost:27017/mydb?authSource=admin');
```

### Python (PyMongo)

```python
from pymongo import MongoClient
client = MongoClient('mongodb://admin:admin@localhost:27017/?authSource=admin')
db = client.mydb
```

### Go (mongo-driver)

```go
import "go.mongodb.org/mongo-driver/mongo"

clientOptions := options.Client().ApplyURI(
    "mongodb://admin:admin@localhost:27017/?authSource=admin",
)
client, _ := mongo.Connect(context.TODO(), clientOptions)
```


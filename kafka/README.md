# Kafka Template

Шаблон для быстрого запуска Apache Kafka в режиме KRaft (без ZooKeeper) с необходимыми инструментами.

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

- **Apache Kafka 8.0.0** (KRaft режим)
  - Порт для клиентов: `29092` (настраивается через `KAFKA_PORT`)
  - JMX порт: `9101` (настраивается через `KAFKA_JMX_PORT`)

- **Kafka UI** — веб-интерфейс для управления Kafka
  - Порт: `8080` (настраивается через `KAFKA_UI_PORT`)
  - URL: http://localhost:8080

- **Schema Registry** — управление схемами данных
  - Порт: `8081` (настраивается через `SCHEMA_REGISTRY_PORT`)
  - URL: http://localhost:8081

- **Kafka Connect** — интеграция с внешними системами
  - Порт: `8083` (настраивается через `KAFKA_CONNECT_PORT`)
  - URL: http://localhost:8083

## Полезные команды

```bash
# Создать топик
docker exec -it kafka-dev kafka-topics --create \
  --bootstrap-server localhost:29092 \
  --topic my-topic \
  --partitions 3 \
  --replication-factor 1

# Список топиков
docker exec -it kafka-dev kafka-topics --list \
  --bootstrap-server localhost:29092

# Отправить сообщение
docker exec -it kafka-dev kafka-console-producer \
  --bootstrap-server localhost:29092 \
  --topic my-topic

# Читать сообщения
docker exec -it kafka-dev kafka-console-consumer \
  --bootstrap-server localhost:29092 \
  --topic my-topic \
  --from-beginning

# Остановка
docker-compose down
```


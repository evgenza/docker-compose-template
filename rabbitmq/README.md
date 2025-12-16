# RabbitMQ Template

Шаблон для быстрого запуска RabbitMQ с веб-интерфейсом управления.

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

- **RabbitMQ 3.12** (Management Plugin включен)
  - AMQP порт: `5672` (настраивается через `RABBITMQ_PORT`)
  - Management UI порт: `15672` (настраивается через `RABBITMQ_MANAGEMENT_PORT`)
  - URL Management UI: http://localhost:15672
  - Данные сохраняются в volume `rabbitmq_data`

## Полезные команды

```bash
# Подключение к RabbitMQ CLI
docker exec -it rabbitmq-dev rabbitmqctl status

# Список очередей
docker exec -it rabbitmq-dev rabbitmqctl list_queues

# Список exchanges
docker exec -it rabbitmq-dev rabbitmqctl list_exchanges

# Список пользователей
docker exec -it rabbitmq-dev rabbitmqctl list_users

# Создать пользователя
docker exec -it rabbitmq-dev rabbitmqctl add_user myuser mypassword

# Создать виртуальный хост
docker exec -it rabbitmq-dev rabbitmqctl add_vhost myvhost

# Дать права пользователю
docker exec -it rabbitmq-dev rabbitmqctl set_permissions -p myvhost myuser ".*" ".*" ".*"

# Остановка
docker-compose down
```

## Примеры использования

### Node.js (amqplib)

```javascript
const amqp = require('amqplib');

async function connect() {
  const connection = await amqp.connect('amqp://admin:admin@localhost:5672');
  const channel = await connection.createChannel();
  
  const queue = 'my-queue';
  await channel.assertQueue(queue);
  
  // Отправка сообщения
  channel.sendToQueue(queue, Buffer.from('Hello RabbitMQ!'));
  
  // Получение сообщения
  channel.consume(queue, (msg) => {
    console.log(msg.content.toString());
    channel.ack(msg);
  });
}
```

### Python (pika)

```python
import pika

connection = pika.BlockingConnection(
    pika.URLParameters('amqp://admin:admin@localhost:5672/%2F')
)
channel = connection.channel()

queue = 'my-queue'
channel.queue_declare(queue=queue)

# Отправка сообщения
channel.basic_publish(exchange='', routing_key=queue, body='Hello RabbitMQ!')

# Получение сообщения
def callback(ch, method, properties, body):
    print(f"Received: {body}")

channel.basic_consume(queue=queue, on_message_callback=callback, auto_ack=True)
channel.start_consuming()
```

### Go (amqp091-go)

```go
import "github.com/rabbitmq/amqp091-go"

conn, _ := amqp091.Dial("amqp://admin:admin@localhost:5672/")
defer conn.Close()

ch, _ := conn.Channel()
defer ch.Close()

q, _ := ch.QueueDeclare("my-queue", false, false, false, false, nil)

// Отправка сообщения
ch.Publish("", q.Name, false, false, amqp091.Publishing{
    ContentType: "text/plain",
    Body:        []byte("Hello RabbitMQ!"),
})

// Получение сообщения
msgs, _ := ch.Consume(q.Name, "", true, false, false, false, nil)
for msg := range msgs {
    fmt.Printf("Received: %s\n", msg.Body)
}
```

## Management UI

Веб-интерфейс доступен по адресу http://localhost:15672

- Логин: `admin` (или значение из `RABBITMQ_USER`)
- Пароль: `admin` (или значение из `RABBITMQ_PASSWORD`)

В интерфейсе можно:
- Просматривать очереди, exchanges, bindings
- Мониторить производительность
- Управлять пользователями и виртуальными хостами
- Просматривать сообщения в очередях

## Основные концепции

- **Queue** — очередь сообщений
- **Exchange** — маршрутизатор сообщений (direct, topic, fanout, headers)
- **Binding** — связь между exchange и queue
- **Routing Key** — ключ маршрутизации сообщений
- **Virtual Host** — логическое разделение ресурсов


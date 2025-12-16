# MinIO Template

Шаблон для быстрого запуска MinIO — S3-совместимого объектного хранилища.

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

- **MinIO** — S3-совместимое объектное хранилище
  - API порт: `9000` (настраивается через `MINIO_API_PORT`)
  - Console порт: `9001` (настраивается через `MINIO_CONSOLE_PORT`)
  - Console URL: http://localhost:9001
  - Данные сохраняются в volume `minio_data`

## Доступ к Console

После запуска откройте http://localhost:9001 и войдите с учетными данными:
- Логин: `admin` (или значение из `MINIO_ROOT_USER`)
- Пароль: `admin123456` (или значение из `MINIO_ROOT_PASSWORD`)

## Полезные команды

```bash
# Установка MinIO Client (mc)
# macOS
brew install minio/stable/mc

# Linux
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

# Настройка клиента
mc alias set local http://localhost:9000 admin admin123456

# Создать bucket
mc mb local/my-bucket

# Загрузить файл
mc cp file.txt local/my-bucket/

# Скачать файл
mc cp local/my-bucket/file.txt ./

# Список файлов
mc ls local/my-bucket/

# Удалить файл
mc rm local/my-bucket/file.txt

# Остановка
docker-compose down
```

## Примеры использования

### Node.js (aws-sdk или @aws-sdk/client-s3)

```javascript
const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  endpoint: 'http://localhost:9000',
  accessKeyId: 'admin',
  secretAccessKey: 'admin123456',
  s3ForcePathStyle: true,
  signatureVersion: 'v4'
});

// Загрузить файл
const uploadParams = {
  Bucket: 'my-bucket',
  Key: 'file.txt',
  Body: 'Hello MinIO!'
};
s3.upload(uploadParams).promise();

// Скачать файл
const downloadParams = {
  Bucket: 'my-bucket',
  Key: 'file.txt'
};
const data = await s3.getObject(downloadParams).promise();
console.log(data.Body.toString());
```

### Python (boto3)

```python
import boto3
from botocore.client import Config

s3 = boto3.client(
    's3',
    endpoint_url='http://localhost:9000',
    aws_access_key_id='admin',
    aws_secret_access_key='admin123456',
    config=Config(signature_version='s3v4')
)

# Загрузить файл
s3.upload_file('file.txt', 'my-bucket', 'file.txt')

# Скачать файл
s3.download_file('my-bucket', 'file.txt', 'downloaded.txt')

# Список объектов
objects = s3.list_objects_v2(Bucket='my-bucket')
for obj in objects.get('Contents', []):
    print(obj['Key'])
```

### Go (aws-sdk-go-v2)

```go
import (
    "github.com/aws/aws-sdk-go-v2/aws"
    "github.com/aws/aws-sdk-go-v2/config"
    "github.com/aws/aws-sdk-go-v2/service/s3"
)

cfg, _ := config.LoadDefaultConfig(context.TODO(),
    config.WithEndpointResolver(aws.EndpointResolverFunc(
        func(service, region string) (aws.Endpoint, error) {
            return aws.Endpoint{URL: "http://localhost:9000"}, nil
        },
    )),
    config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(
        "admin", "admin123456", "",
    )),
)

client := s3.NewFromConfig(cfg)

// Загрузить файл
file, _ := os.Open("file.txt")
client.PutObject(context.TODO(), &s3.PutObjectInput{
    Bucket: aws.String("my-bucket"),
    Key:    aws.String("file.txt"),
    Body:   file,
})
```

## Использование с приложениями

MinIO полностью совместим с Amazon S3 API, поэтому любая библиотека или инструмент, работающий с S3, будет работать с MinIO. Просто измените endpoint на `http://localhost:9000`.

## Безопасность

⚠️ **Важно для продакшена:**

- Измените пароль по умолчанию
- Используйте TLS/SSL для шифрования трафика
- Настройте политики доступа через Console
- Используйте IAM для управления пользователями и правами доступа


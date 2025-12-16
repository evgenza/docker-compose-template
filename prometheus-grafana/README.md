# Prometheus + Grafana Template

Шаблон для быстрого запуска системы мониторинга с Prometheus и Grafana.

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

- **Prometheus** — система мониторинга и сбора метрик
  - Порт: `9090` (настраивается через `PROMETHEUS_PORT`)
  - URL: http://localhost:9090
  - Данные сохраняются в volume `prometheus_data`
  - Хранение метрик: 30 дней

- **Grafana** — платформа для визуализации и анализа метрик
  - Порт: `3000` (настраивается через `GRAFANA_PORT`)
  - URL: http://localhost:3000
  - Данные сохраняются в volume `grafana_data`
  - Prometheus автоматически настроен как источник данных

- **Node Exporter** — экспорт метрик системы (CPU, память, диск, сеть)
  - Порт: `9100` (настраивается через `NODE_EXPORTER_PORT`)

## Конфигурация

### Prometheus

Конфигурация находится в `prometheus/prometheus.yml`:
- Интервал сбора метрик: 15 секунд
- Настроены targets для Prometheus и Node Exporter
- Правила алертов в `prometheus/alerts.yml`

### Grafana

- Источники данных настраиваются автоматически через `grafana/provisioning/datasources/`
- Дашборды можно добавлять в `grafana/dashboards/`
- Или создавать через веб-интерфейс Grafana

## Полезные команды

```bash
# Перезагрузить конфигурацию Prometheus
curl -X POST http://localhost:9090/-/reload

# Проверить статус Prometheus
curl http://localhost:9090/-/healthy

# Просмотр метрик
curl http://localhost:9090/api/v1/query?query=up

# Остановка
docker-compose down
```

## Добавление новых метрик

### 1. Добавить новый scrape target в `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['my-app:8080']
```

### 2. Перезагрузить конфигурацию:

```bash
curl -X POST http://localhost:9090/-/reload
```

## Примеры использования

### Интеграция с приложением (Node.js)

```javascript
const promClient = require('prom-client');
const register = new promClient.Registry();

promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  buckets: [0.1, 0.5, 1, 2, 5]
});

// Экспорт метрик на /metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Интеграция с приложением (Python)

```python
from prometheus_client import start_http_server, Counter, Histogram
import time

REQUEST_COUNT = Counter('requests_total', 'Total requests')
REQUEST_DURATION = Histogram('request_duration_seconds', 'Request duration')

# Запустить сервер метрик на порту 8000
start_http_server(8000)
```

## Готовые дашборды

После запуска Grafana вы можете:
1. Импортировать готовые дашборды из [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
2. Популярные ID: `1860` (Node Exporter), `11074` (Prometheus Stats)

## Алерты

Правила алертов настраиваются в `prometheus/alerts.yml`. Для отправки уведомлений можно добавить Alertmanager.


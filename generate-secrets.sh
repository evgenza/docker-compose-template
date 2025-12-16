#!/bin/bash

# Скрипт для генерации случайных секретов и обновления .env файлов
# Использование: ./generate-secrets.sh

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для генерации случайного пароля
generate_password() {
    local length=${1:-16}
    # Генерируем пароль из букв, цифр и специальных символов
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
}

# Функция для генерации случайного пароля без специальных символов (для некоторых сервисов)
generate_simple_password() {
    local length=${1:-16}
    openssl rand -hex ${length} | cut -c1-${length}
}

echo -e "${BLUE}🔐 Генерация секретов для Docker Compose шаблона${NC}"
echo "=========================================="
echo ""

# Генерируем все секреты
echo -e "${YELLOW}Генерация случайных паролей...${NC}"

POSTGRES_PASSWORD=$(generate_password 20)
PGADMIN_PASSWORD=$(generate_password 16)
MONGODB_PASSWORD=$(generate_password 20)
MONGO_EXPRESS_PASSWORD=$(generate_password 16)
REDIS_PASSWORD=$(generate_password 20)
REDIS_COMMANDER_PASSWORD=$(generate_password 16)
RABBITMQ_PASSWORD=$(generate_password 20)
MINIO_ROOT_PASSWORD=$(generate_password 20)
GRAFANA_PASSWORD=$(generate_password 16)

echo -e "${GREEN}✅ Пароли сгенерированы${NC}"
echo ""

# Обновляем корневой .env файл
if [ -f .env.example ]; then
    echo -e "${BLUE}📝 Обновление корневого .env файла...${NC}"
    
    if [ ! -f .env ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Создан файл .env из .env.example${NC}"
    fi
    
    # Определяем команду sed в зависимости от ОС
    if [[ "$OSTYPE" == "darwin"* ]]; then
        SED_INPLACE="sed -i.bak"
    else
        SED_INPLACE="sed -i"
    fi
    
    # Обновляем пароли в корневом .env (используем | вместо / для разделителя, чтобы избежать проблем с символами)
    $SED_INPLACE "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${POSTGRES_PASSWORD}|" .env
    $SED_INPLACE "s|^PGADMIN_PASSWORD=.*|PGADMIN_PASSWORD=${PGADMIN_PASSWORD}|" .env
    $SED_INPLACE "s|^MONGODB_PASSWORD=.*|MONGODB_PASSWORD=${MONGODB_PASSWORD}|" .env
    $SED_INPLACE "s|^MONGO_EXPRESS_PASSWORD=.*|MONGO_EXPRESS_PASSWORD=${MONGO_EXPRESS_PASSWORD}|" .env
    $SED_INPLACE "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PASSWORD}|" .env
    $SED_INPLACE "s|^REDIS_COMMANDER_PASSWORD=.*|REDIS_COMMANDER_PASSWORD=${REDIS_COMMANDER_PASSWORD}|" .env
    $SED_INPLACE "s|^RABBITMQ_PASSWORD=.*|RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}|" .env
    $SED_INPLACE "s|^MINIO_ROOT_PASSWORD=.*|MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}|" .env
    $SED_INPLACE "s|^GRAFANA_PASSWORD=.*|GRAFANA_PASSWORD=${GRAFANA_PASSWORD}|" .env
    
    # Удаляем backup файл
    rm -f .env.bak
    
    echo -e "${GREEN}✅ Корневой .env обновлен${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  Файл .env.example не найден в корне${NC}"
fi

# Обновляем .env файлы в подпапках
declare -a services=("postgres" "mongodb" "redis" "kafka" "rabbitmq" "minio" "prometheus-grafana")

for service in "${services[@]}"; do
    if [ -d "$service" ] && [ -f "$service/.env.example" ]; then
        echo -e "${BLUE}📝 Обновление $service/.env...${NC}"
        
        if [ ! -f "$service/.env" ]; then
            cp "$service/.env.example" "$service/.env"
            echo -e "${GREEN}✅ Создан файл $service/.env${NC}"
        fi
        
        # Обновляем пароли в зависимости от сервиса
        # Используем разные методы sed для macOS и Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            SED_INPLACE="sed -i.bak"
        else
            SED_INPLACE="sed -i"
        fi
        
        case "$service" in
            "postgres")
                $SED_INPLACE "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${POSTGRES_PASSWORD}|" "$service/.env" 2>/dev/null || true
                $SED_INPLACE "s|^PGADMIN_PASSWORD=.*|PGADMIN_PASSWORD=${PGADMIN_PASSWORD}|" "$service/.env" 2>/dev/null || true
                ;;
            "mongodb")
                $SED_INPLACE "s|^MONGODB_PASSWORD=.*|MONGODB_PASSWORD=${MONGODB_PASSWORD}|" "$service/.env" 2>/dev/null || true
                $SED_INPLACE "s|^MONGO_EXPRESS_PASSWORD=.*|MONGO_EXPRESS_PASSWORD=${MONGO_EXPRESS_PASSWORD}|" "$service/.env" 2>/dev/null || true
                ;;
            "redis")
                # Redis может иметь пустой пароль, обновляем только если есть значение
                if grep -q "^REDIS_PASSWORD=" "$service/.env" 2>/dev/null; then
                    $SED_INPLACE "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PASSWORD}|" "$service/.env" 2>/dev/null || true
                fi
                $SED_INPLACE "s|^REDIS_COMMANDER_PASSWORD=.*|REDIS_COMMANDER_PASSWORD=${REDIS_COMMANDER_PASSWORD}|" "$service/.env" 2>/dev/null || true
                ;;
            "rabbitmq")
                $SED_INPLACE "s|^RABBITMQ_PASSWORD=.*|RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD}|" "$service/.env" 2>/dev/null || true
                ;;
            "minio")
                $SED_INPLACE "s|^MINIO_ROOT_PASSWORD=.*|MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}|" "$service/.env" 2>/dev/null || true
                ;;
            "prometheus-grafana")
                $SED_INPLACE "s|^GRAFANA_PASSWORD=.*|GRAFANA_PASSWORD=${GRAFANA_PASSWORD}|" "$service/.env" 2>/dev/null || true
                ;;
        esac
        
        # Удаляем backup файлы (только для macOS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            rm -f "$service/.env.bak"
        fi
        
        echo -e "${GREEN}✅ $service/.env обновлен${NC}"
    else
        echo -e "${YELLOW}⚠️  Пропуск $service (нет .env.example)${NC}"
    fi
done

echo ""
echo -e "${GREEN}✨ Готово! Все секреты сгенерированы и обновлены${NC}"
echo ""
echo -e "${YELLOW}📋 Сгенерированные пароли:${NC}"
echo "=========================================="
echo "PostgreSQL:        ${POSTGRES_PASSWORD}"
echo "pgAdmin:           ${PGADMIN_PASSWORD}"
echo "MongoDB:           ${MONGODB_PASSWORD}"
echo "Mongo Express:     ${MONGO_EXPRESS_PASSWORD}"
echo "Redis:             ${REDIS_PASSWORD}"
echo "Redis Commander:   ${REDIS_COMMANDER_PASSWORD}"
echo "RabbitMQ:          ${RABBITMQ_PASSWORD}"
echo "MinIO:             ${MINIO_ROOT_PASSWORD}"
echo "Grafana:           ${GRAFANA_PASSWORD}"
echo "=========================================="
echo ""
echo -e "${BLUE}💡 Совет: Сохраните эти пароли в безопасном месте!${NC}"
echo ""


#!/bin/bash

# Скрипт для генерации случайных секретов для Redis
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
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
}

echo -e "${BLUE}🔐 Генерация секретов для Redis${NC}"
echo "=========================================="
echo ""

# Генерируем секреты
echo -e "${YELLOW}Генерация случайных паролей...${NC}"
REDIS_PASSWORD=$(generate_password 20)
REDIS_COMMANDER_PASSWORD=$(generate_password 16)

echo -e "${GREEN}✅ Пароли сгенерированы${NC}"
echo ""

# Обновляем .env файл
if [ -f .env.example ]; then
    echo -e "${BLUE}📝 Обновление .env файла...${NC}"
    
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
    
    # Обновляем пароли (Redis может иметь пустой пароль)
    if grep -q "^REDIS_PASSWORD=" .env 2>/dev/null; then
        $SED_INPLACE "s|^REDIS_PASSWORD=.*|REDIS_PASSWORD=${REDIS_PASSWORD}|" .env
    else
        echo "REDIS_PASSWORD=${REDIS_PASSWORD}" >> .env
    fi
    $SED_INPLACE "s|^REDIS_COMMANDER_PASSWORD=.*|REDIS_COMMANDER_PASSWORD=${REDIS_COMMANDER_PASSWORD}|" .env
    
    # Удаляем backup файл
    if [[ "$OSTYPE" == "darwin"* ]]; then
        rm -f .env.bak
    fi
    
    echo -e "${GREEN}✅ .env обновлен${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  Файл .env.example не найден${NC}"
    exit 1
fi

echo -e "${GREEN}✨ Готово! Секреты сгенерированы${NC}"
echo ""
echo -e "${YELLOW}📋 Сгенерированные пароли:${NC}"
echo "=========================================="
echo "Redis:            ${REDIS_PASSWORD}"
echo "Redis Commander:  ${REDIS_COMMANDER_PASSWORD}"
echo "=========================================="
echo ""
echo -e "${BLUE}💡 Совет: Сохраните эти пароли в безопасном месте!${NC}"
echo ""


#!/bin/bash

# Скрипт развертывания исламского образовательного портала

echo "🚀 Запуск развертывания исламского образовательного портала..."

# Проверка наличия Docker и Docker Compose
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Пожалуйста, установите Docker."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose не установлен. Пожалуйста, установите Docker Compose."
    exit 1
fi

# Проверка наличия .env файла
if [ ! -f .env ]; then
    echo "📋 Создание .env файла из .env.example..."
    cp .env.example .env
    echo "✅ Файл .env создан. Пожалуйста, настройте его перед продолжением."
    echo "⚠️  Особенно важно изменить:"
    echo "   - JWT_SECRET"
    echo "   - MONGO_ROOT_PASSWORD"
    echo "   - REACT_APP_BACKEND_URL (для production)"
    read -p "Нажмите Enter после настройки .env файла..."
fi

# Создание необходимых директорий
echo "📁 Создание необходимых директорий..."
mkdir -p uploads
mkdir -p nginx/ssl
chmod 755 uploads

# Остановка и удаление старых контейнеров
echo "🛑 Остановка старых контейнеров..."
docker-compose down

# Сборка и запуск контейнеров
echo "🔨 Сборка и запуск контейнеров..."
docker-compose up --build -d

# Ожидание запуска сервисов
echo "⏳ Ожидание запуска сервисов..."
sleep 30

# Проверка статуса сервисов
echo "📊 Проверка статуса сервисов..."
docker-compose ps

# Проверка доступности API
echo "🔍 Проверка доступности API..."
if curl -f http://localhost:8001/api/health > /dev/null 2>&1; then
    echo "✅ Backend API доступен"
else
    echo "⚠️  Backend API недоступен, проверьте логи: docker-compose logs backend"
fi

# Проверка доступности Frontend
echo "🔍 Проверка доступности Frontend..."
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend доступен"
else
    echo "⚠️  Frontend недоступен, проверьте логи: docker-compose logs frontend"
fi

echo ""
echo "🎉 Развертывание завершено!"
echo "📱 Доступ к приложению:"
echo "   - Frontend: http://localhost:3000"
echo "   - Backend API: http://localhost:8001"
echo "   - Nginx: http://localhost:80"
echo ""
echo "👨‍💼 Данные администратора:"
echo "   - Логин: admin"
echo "   - Пароль: admin123"
echo ""
echo "📋 Полезные команды:"
echo "   - Просмотр логов: docker-compose logs [service]"
echo "   - Остановка: docker-compose down"
echo "   - Перезапуск: docker-compose restart"
echo "   - Обновление: docker-compose pull && docker-compose up -d"
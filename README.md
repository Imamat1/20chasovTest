# Исламский образовательный портал

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![MongoDB](https://img.shields.io/badge/database-MongoDB-green.svg)
![React](https://img.shields.io/badge/frontend-React-blue.svg)
![FastAPI](https://img.shields.io/badge/backend-FastAPI-green.svg)

Полнофункциональная платформа для исламского образования с системой курсов, тестов, Q&A и администрирования.

## 🌟 Возможности

- **📚 Система курсов и уроков** - Создание и управление образовательными курсами
- **📝 Система тестирования** - Тесты с множественным выбором и автоматической проверкой
- **❓ Q&A система** - Вопросы и ответы от имама
- **👥 Управление командой** - Раздел "Наша команда" с фотографиями
- **🔐 Админ-панель** - Полное управление контентом
- **📊 Система лидерборда** - Рейтинг учащихся
- **🎬 Видео интеграция** - Поддержка YouTube видео
- **📁 Загрузка файлов** - Загрузка PDF, DOCX и других материалов

## 🛠 Технологический стек

### Backend
- **FastAPI** - Современный веб-фреймворк для Python
- **MongoDB** - NoSQL база данных
- **JWT** - Аутентификация и авторизация
- **Python 3.11** - Язык программирования

### Frontend
- **React 19** - Библиотека для создания пользовательских интерфейсов
- **Tailwind CSS** - CSS фреймворк
- **Axios** - HTTP клиент
- **React Router** - Маршрутизация

### Infrastructure
- **Docker & Docker Compose** - Контейнеризация
- **Nginx** - Веб-сервер и прокси
- **Alpine Linux** - Легковесная операционная система

## 🚀 Быстрый старт

### Требования
- Docker и Docker Compose
- Git
- 4GB RAM минимум
- 10GB свободного места на диске

### Установка

1. **Клонирование репозитория**
```bash
git clone https://github.com/your-username/islam-education-portal.git
cd islam-education-portal
```

2. **Настройка переменных окружения**
```bash
cp .env.example .env
# Отредактируйте .env файл согласно вашим настройкам
```

3. **Запуск приложения**
```bash
chmod +x deploy.sh
./deploy.sh
```

4. **Проверка работы**
- Frontend: http://localhost:3000
- Backend API: http://localhost:8001
- Nginx: http://localhost:80

## ⚙️ Настройка окружения

### Основные переменные в .env файле:

```env
# База данных
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your-secure-password
DB_NAME=islam_education

# Безопасность
JWT_SECRET=your-super-secret-jwt-key

# Frontend
REACT_APP_BACKEND_URL=http://localhost:8001

# Для production
# REACT_APP_BACKEND_URL=https://your-domain.com/api
```

## 🔐 Администрирование

### Данные администратора по умолчанию:
- **Логин:** admin
- **Пароль:** admin123

⚠️ **Важно:** Измените пароль администратора после первого входа!

### Доступ к админ-панели:
- Прямая ссылка: http://localhost:3000/admin
- Или нажмите кнопку "🔧 Админ панель" в правом нижнем углу сайта

## 📦 Развертывание на DigitalOcean

### Пошаговая инструкция:

1. **Создание Droplet**
```bash
# Создайте новый Droplet Ubuntu 22.04
# Минимальные требования: 2GB RAM, 1 CPU, 25GB SSD
```

2. **Подключение к серверу**
```bash
ssh root@your-server-ip
```

3. **Установка Docker**
```bash
# Обновление системы
apt update && apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
apt install docker-compose -y

# Проверка установки
docker --version
docker-compose --version
```

4. **Клонирование и настройка проекта**
```bash
# Клонирование репозитория
git clone https://github.com/your-username/islam-education-portal.git
cd islam-education-portal

# Настройка переменных окружения
cp .env.example .env
nano .env

# Важно: Обновите следующие переменные:
# REACT_APP_BACKEND_URL=https://your-domain.com/api
# JWT_SECRET=your-production-secret
# MONGO_ROOT_PASSWORD=your-secure-password
```

5. **Настройка домена и SSL**
```bash
# Добавьте A-запись в DNS:
# your-domain.com -> IP сервера

# Для SSL сертификата (опционально):
# Разместите cert.pem и key.pem в nginx/ssl/
```

6. **Запуск приложения**
```bash
chmod +x deploy.sh
./deploy.sh
```

7. **Настройка Nginx для production**
```bash
# Отредактируйте nginx/nginx.conf для вашего домена
# Раскомментируйте блок HTTPS, если используете SSL
```

### Управление сервисами:

```bash
# Просмотр статуса
docker-compose ps

# Просмотр логов
docker-compose logs [service-name]

# Перезапуск сервиса
docker-compose restart [service-name]

# Остановка всех сервисов
docker-compose down

# Обновление и перезапуск
git pull
docker-compose up --build -d
```

## 📊 Мониторинг и обслуживание

### Резервное копирование MongoDB:
```bash
# Создание backup
docker exec islam_mongodb mongodump --out /backup

# Восстановление backup
docker exec islam_mongodb mongorestore /backup
```

### Очистка Docker:
```bash
# Удаление неиспользуемых образов
docker image prune -f

# Очистка всех неиспользуемых ресурсов
docker system prune -af
```

### Мониторинг ресурсов:
```bash
# Использование ресурсов контейнерами
docker stats

# Свободное место
df -h

# Использование памяти
free -h
```

## 🔧 Разработка

### Локальная разработка:
```bash
# Backend
cd backend
pip install -r requirements.txt
uvicorn server:app --reload

# Frontend
cd frontend
yarn install
yarn start
```

### Структура проекта:
```
islam-education-portal/
├── backend/                 # FastAPI приложение
│   ├── server.py           # Основной файл сервера
│   ├── models.py           # Модели данных
│   ├── requirements.txt    # Python зависимости
│   └── Dockerfile         # Docker конфигурация
├── frontend/               # React приложение
│   ├── src/               # Исходный код
│   ├── public/            # Статические файлы
│   ├── package.json       # Node.js зависимости
│   └── Dockerfile        # Docker конфигурация
├── nginx/                 # Nginx конфигурация
├── uploads/               # Загруженные файлы
├── docker-compose.yml     # Оркестрация контейнеров
├── .env.example          # Пример переменных окружения
└── deploy.sh             # Скрипт развертывания
```

## 🐛 Решение проблем

### Частые проблемы:

1. **Контейнер не запускается**
```bash
docker-compose logs [service-name]
```

2. **Ошибки подключения к базе данных**
```bash
# Проверьте переменные окружения
cat .env

# Перезапустите MongoDB
docker-compose restart mongodb
```

3. **Фронтенд не может подключиться к API**
```bash
# Проверьте REACT_APP_BACKEND_URL в .env
# Убедитесь, что backend запущен
curl http://localhost:8001/api/health
```

4. **Проблемы с загрузкой файлов**
```bash
# Проверьте права доступа к папке uploads
chmod 755 uploads
```

## 📝 API Документация

После запуска приложения, API документация доступна по адресу:
- **Swagger UI:** http://localhost:8001/docs
- **ReDoc:** http://localhost:8001/redoc

## 🤝 Вклад в проект

1. Форкните репозиторий
2. Создайте ветку для новой функции (`git checkout -b feature/amazing-feature`)
3. Зафиксируйте изменения (`git commit -m 'Add amazing feature'`)
4. Отправьте в ветку (`git push origin feature/amazing-feature`)
5. Создайте Pull Request

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для подробностей.

## 👥 Авторы

- **Команда разработки** - *Первоначальная работа*

## 🙏 Благодарности

- Всем, кто внес вклад в развитие проекта
- Сообществу открытого исходного кода
- Исламскому образовательному сообществу

---

**Для поддержки и вопросов:**
- Создайте Issue в GitHub
- Напишите в Discussions
- Следите за обновлениями
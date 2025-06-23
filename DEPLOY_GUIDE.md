# 🚀 Подробное руководство по развертыванию

## Быстрое развертывание на DigitalOcean

### 1. Создание Droplet

1. Войдите в панель управления DigitalOcean
2. Нажмите "Create" → "Droplet"
3. Выберите конфигурацию:
   - **OS**: Ubuntu 22.04 LTS
   - **Plan**: Basic
   - **CPU options**: Regular Intel (минимум 2GB RAM, 1 vCPU)
   - **Storage**: 25GB SSD (минимум)
   - **Datacenter**: Выберите ближайший к вашим пользователям

### 2. Начальная настройка сервера

```bash
# Подключение к серверу
ssh root@YOUR_SERVER_IP

# Обновление системы
apt update && apt upgrade -y

# Установка необходимых пакетов
apt install -y curl git ufw

# Настройка файрвола
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

### 3. Установка Docker

```bash
# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Установка Docker Compose
apt install -y docker-compose

# Проверка установки
docker --version
docker-compose --version

# Добавление пользователя в группу docker (опционально)
usermod -aG docker $USER
```

### 4. Развертывание приложения

```bash
# Клонирование репозитория
git clone https://github.com/YOUR_USERNAME/islam-education-portal.git
cd islam-education-portal

# Настройка production окружения
chmod +x production-setup.sh
./production-setup.sh your-domain.com

# Редактирование .env файла (важно!)
nano .env
# Убедитесь, что установлены правильные значения:
# - REACT_APP_BACKEND_URL=https://your-domain.com/api
# - Сложные пароли для MONGO_ROOT_PASSWORD и JWT_SECRET
```

### 5. Настройка DNS

1. В панели управления вашего домена создайте A-записи:
   - `your-domain.com` → IP сервера
   - `www.your-domain.com` → IP сервера

2. Подождите распространения DNS (обычно 5-15 минут)

### 6. Получение SSL сертификата

```bash
# Запуск скрипта получения SSL сертификата
chmod +x get-ssl-cert.sh
./get-ssl-cert.sh your-domain.com admin@your-domain.com
```

### 7. Запуск приложения

```bash
# Запуск через deploy скрипт
chmod +x deploy.sh
./deploy.sh
```

### 8. Проверка работы

```bash
# Проверка статуса контейнеров
docker-compose ps

# Проверка логов
docker-compose logs

# Проверка доступности
curl https://your-domain.com
curl https://your-domain.com/api/health
```

## Альтернативное развертывание без домена (только IP)

Если у вас нет домена, можете развернуть на IP адресе:

```bash
# В .env файле используйте:
REACT_APP_BACKEND_URL=http://YOUR_SERVER_IP:8001

# Запуск без SSL
docker-compose up -d mongodb backend frontend

# Доступ через:
# http://YOUR_SERVER_IP:3000 - Frontend
# http://YOUR_SERVER_IP:8001 - Backend API
```

## Обслуживание и мониторинг

### Мониторинг системы

```bash
# Запуск скрипта мониторинга
chmod +x monitor.sh
./monitor.sh

# Настройка автоматического мониторинга
crontab -e
# Добавьте строку:
# */15 * * * * /path/to/your/app/monitor.sh >> /var/log/islam-monitor.log
```

### Резервное копирование

```bash
# Создание резервной копии
chmod +x backup.sh
./backup.sh

# Настройка автоматического backup
crontab -e
# Добавьте строку:
# 0 2 * * * /path/to/your/app/backup.sh
```

### Управление сервисами

```bash
# Перезапуск всех сервисов
docker-compose restart

# Перезапуск отдельного сервиса
docker-compose restart backend

# Просмотр логов конкретного сервиса
docker-compose logs -f backend

# Обновление и перезапуск
git pull
docker-compose down
docker-compose up --build -d
```

### Масштабирование

```bash
# Для увеличения производительности можете создать несколько экземпляров backend
docker-compose up -d --scale backend=3

# Или настроить load balancer в nginx.conf:
# upstream backend {
#     server islam_backend:8001;
#     server islam_backend_2:8001;
#     server islam_backend_3:8001;
# }
```

## Решение проблем

### Проблема: Контейнеры не запускаются

```bash
# Проверка логов
docker-compose logs

# Проверка свободного места
df -h

# Очистка Docker
docker system prune -af
```

### Проблема: База данных недоступна

```bash
# Перезапуск MongoDB
docker-compose restart mongodb

# Проверка логов MongoDB
docker-compose logs mongodb

# Подключение к MongoDB для проверки
docker exec -it islam_mongodb mongo
```

### Проблема: SSL сертификат не работает

```bash
# Проверка сертификатов
ls -la nginx/ssl/

# Обновление сертификата
./get-ssl-cert.sh your-domain.com admin@your-domain.com

# Перезапуск nginx
docker-compose restart nginx
```

### Проблема: Высокая нагрузка на сервер

```bash
# Мониторинг ресурсов
htop
docker stats

# Оптимизация nginx
# В nginx/nginx.conf увеличьте worker_processes и worker_connections

# Добавление swap файла (если мало RAM)
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## Настройка для production

### Безопасность

1. **Смена пароля администратора**:
   - Войдите в админ панель: https://your-domain.com/admin
   - Логин: admin, Пароль: admin123
   - Смените пароль в настройках

2. **Настройка файрвола**:
```bash
# Ограничение доступа к SSH только с определенных IP
ufw delete allow OpenSSH
ufw allow from YOUR_OFFICE_IP to any port 22

# Ограничение скорости подключений
ufw limit ssh
```

3. **Регулярные обновления**:
```bash
# Настройка автоматических обновлений безопасности
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

### Производительность

1. **Настройка MongoDB**:
```bash
# В docker-compose.yml добавьте для mongodb:
# command: mongod --wiredTigerCacheSizeGB 1.5
```

2. **Настройка nginx кеширования**:
```bash
# В nginx/nginx.conf уже настроено кеширование статических файлов
# Для дополнительного кеширования API можете добавить Redis
```

3. **Мониторинг производительности**:
```bash
# Установка дополнительных инструментов мониторинга
apt install -y htop iotop nethogs
```

## Обновление приложения

```bash
# Стандартное обновление
git pull
docker-compose down
docker-compose up --build -d

# Обновление с сохранением данных
docker-compose down --remove-orphans
docker-compose pull
docker-compose up -d

# Откат к предыдущей версии
git log --oneline -10  # просмотр последних коммитов
git checkout COMMIT_HASH
docker-compose down
docker-compose up --build -d
```

## Контакты для поддержки

При возникновении проблем:
1. Проверьте логи: `docker-compose logs`
2. Запустите мониторинг: `./monitor.sh`
3. Создайте Issue в GitHub репозитории
4. Приложите логи и описание проблемы

---

**Успешного развертывания вашего исламского образовательного портала! 🚀**
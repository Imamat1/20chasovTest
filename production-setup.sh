#!/bin/bash

# Скрипт настройки production окружения для исламского образовательного портала

echo "🔧 Настройка production окружения..."

# Проверка аргументов
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <your-domain.com>"
    echo "Пример: $0 islam-education.com"
    exit 1
fi

DOMAIN=$1

echo "🌐 Настройка для домена: $DOMAIN"

# Создание production .env файла
echo "📝 Создание production .env файла..."
cat > .env << EOF
# Production Configuration for $DOMAIN

# Database Configuration
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=$(openssl rand -base64 32)
DB_NAME=islam_education

# Security
JWT_SECRET=$(openssl rand -base64 64)

# Frontend Configuration
REACT_APP_BACKEND_URL=https://$DOMAIN/api
DOMAIN=$DOMAIN

# Email Configuration (optional)
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USERNAME=your-email@gmail.com
# SMTP_PASSWORD=your-app-password
EOF

echo "✅ Production .env файл создан с случайными паролями"

# Обновление nginx конфигурации для production
echo "🔧 Обновление nginx конфигурации..."
cat > nginx/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Performance
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    # File upload limits
    client_max_body_size 100M;
    client_body_timeout 60s;
    client_header_timeout 60s;

    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone \$binary_remote_addr zone=login:10m rate=1r/s;

    # Upstream servers
    upstream backend {
        server islam_backend:8001;
    }

    upstream frontend {
        server islam_frontend:3000;
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        return 301 https://\$server_name\$request_uri;
    }

    # HTTPS server
    server {
        listen 443 ssl http2;
        server_name $DOMAIN www.$DOMAIN;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;

        # API endpoints with rate limiting
        location /api/admin/login {
            limit_req zone=login burst=5 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            client_max_body_size 10M;
        }

        location /api {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            client_max_body_size 100M;
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
        }

        # Static files (uploads)
        location /uploads {
            alias /usr/share/nginx/uploads;
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header Access-Control-Allow-Origin "*";
        }

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            
            # Cache static assets
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                proxy_pass http://frontend;
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }
    }
}
EOF

echo "✅ Nginx конфигурация обновлена для $DOMAIN"

# Создание скрипта для получения SSL сертификата
echo "🔐 Создание скрипта для SSL сертификата..."
cat > get-ssl-cert.sh << 'EOF'
#!/bin/bash

# Скрипт для получения SSL сертификата с Let's Encrypt

if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <domain> <email>"
    echo "Пример: $0 islam-education.com admin@islam-education.com"
    exit 1
fi

DOMAIN=$1
EMAIL=$2

echo "🌐 Получение SSL сертификата для $DOMAIN..."

# Установка Certbot
sudo apt update
sudo apt install -y certbot

# Временно остановить nginx для получения сертификата
docker-compose down nginx

# Получение сертификата
sudo certbot certonly --standalone \
    --preferred-challenges http \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

# Копирование сертификатов
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/key.pem
sudo chown $USER:$USER nginx/ssl/*

echo "✅ SSL сертификат установлен"

# Создание cron задачи для автоматического обновления
echo "📅 Настройка автоматического обновления сертификата..."
(crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet --deploy-hook 'docker-compose restart nginx'") | crontab -

echo "✅ Автоматическое обновление сертификата настроено"

# Перезапуск nginx
docker-compose up -d nginx

echo "🎉 SSL настроен успешно!"
EOF

chmod +x get-ssl-cert.sh

# Создание backup скрипта
echo "💾 Создание скрипта резервного копирования..."
cat > backup.sh << 'EOF'
#!/bin/bash

# Скрипт резервного копирования базы данных

BACKUP_DIR="./backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="islam_education_backup_$DATE.tar.gz"

echo "💾 Создание резервной копии..."

# Создание директории для backup
mkdir -p $BACKUP_DIR

# Backup MongoDB
echo "📊 Создание backup базы данных..."
docker exec islam_mongodb mongodump --out /tmp/backup

# Создание tar архива
echo "📦 Создание архива..."
docker exec islam_mongodb tar -czf /tmp/$BACKUP_FILE -C /tmp backup

# Копирование на хост
docker cp islam_mongodb:/tmp/$BACKUP_FILE $BACKUP_DIR/

# Очистка временных файлов
docker exec islam_mongodb rm -rf /tmp/backup /tmp/$BACKUP_FILE

# Backup uploads
echo "📁 Создание backup загруженных файлов..."
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz uploads/

echo "✅ Резервная копия создана: $BACKUP_DIR/$BACKUP_FILE"
echo "✅ Backup загрузок: $BACKUP_DIR/uploads_backup_$DATE.tar.gz"

# Удаление старых backup (оставляем только последние 7)
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +7 -delete

echo "🧹 Старые backup очищены"
EOF

chmod +x backup.sh

# Создание monitoring скрипта
echo "📊 Создание скрипта мониторинга..."
cat > monitor.sh << 'EOF'
#!/bin/bash

# Скрипт мониторинга системы

echo "🔍 Мониторинг исламского образовательного портала"
echo "=================================================="

# Проверка статуса контейнеров
echo "📦 Статус контейнеров:"
docker-compose ps

echo ""

# Проверка использования ресурсов
echo "💻 Использование ресурсов:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""

# Проверка свободного места
echo "💾 Свободное место на диске:"
df -h

echo ""

# Проверка логов за последние 10 минут
echo "📋 Последние ошибки в логах:"
docker-compose logs --since=10m | grep -i error | tail -10

echo ""

# Проверка доступности API
echo "🌐 Проверка доступности API:"
if curl -f -s http://localhost:8001/api/health > /dev/null; then
    echo "✅ Backend API доступен"
else
    echo "❌ Backend API недоступен"
fi

# Проверка доступности Frontend
if curl -f -s http://localhost:3000 > /dev/null; then
    echo "✅ Frontend доступен"
else
    echo "❌ Frontend недоступен"
fi

# Проверка базы данных
if docker exec islam_mongodb mongo --eval "db.runCommand('ping')" > /dev/null 2>&1; then
    echo "✅ MongoDB доступна"
else
    echo "❌ MongoDB недоступна"
fi

echo ""
echo "📅 Последнее обновление: $(date)"
EOF

chmod +x monitor.sh

echo ""
echo "🎉 Production окружение настроено для $DOMAIN!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Настройте DNS A-запись: $DOMAIN -> IP сервера"
echo "2. Получите SSL сертификат: ./get-ssl-cert.sh $DOMAIN your-email@domain.com"
echo "3. Запустите приложение: ./deploy.sh"
echo "4. Настройте мониторинг: crontab -e и добавьте: */15 * * * * /path/to/monitor.sh"
echo "5. Настройте резервное копирование: crontab -e и добавьте: 0 2 * * * /path/to/backup.sh"
echo ""
echo "📁 Созданные файлы:"
echo "- .env (production конфигурация)"
echo "- nginx/nginx.conf (обновленная конфигурация)"
echo "- get-ssl-cert.sh (скрипт для SSL)"
echo "- backup.sh (скрипт резервного копирования)"
echo "- monitor.sh (скрипт мониторинга)"
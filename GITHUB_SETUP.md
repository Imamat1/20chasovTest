# Инструкции по подготовке к GitHub

## Шаги для загрузки проекта на GitHub:

### 1. Подготовка репозитория

```bash
# Инициализация git репозитория (если еще не сделано)
git init

# Добавление файлов в индекс
git add .

# Первый коммит
git commit -m "Initial commit: Исламский образовательный портал"

# Создание основной ветки
git branch -M main
```

### 2. Создание репозитория на GitHub

1. Перейдите на https://github.com
2. Нажмите "New repository"
3. Заполните:
   - **Repository name**: `islam-education-portal`
   - **Description**: `Исламский образовательный портал с курсами, тестами и Q&A системой`
   - **Visibility**: Public или Private (на ваш выбор)
   - **НЕ инициализируйте** с README, .gitignore или лицензией (они уже есть)

### 3. Подключение к GitHub

```bash
# Добавление удаленного репозитория
git remote add origin https://github.com/YOUR_USERNAME/islam-education-portal.git

# Загрузка кода
git push -u origin main
```

### 4. Настройка GitHub Actions (опционально)

Создайте файл `.github/workflows/deploy.yml` для автоматического развертывания:

```yaml
name: Deploy to DigitalOcean

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        key: ${{ secrets.KEY }}
        script: |
          cd /path/to/islam-education-portal
          git pull origin main
          docker-compose down
          docker-compose up --build -d
```

### 5. Настройка GitHub Secrets

В настройках репозитория GitHub → Settings → Secrets добавьте:
- `HOST`: IP адрес вашего сервера
- `USERNAME`: имя пользователя (обычно `root`)
- `KEY`: приватный SSH ключ

## Структура файлов для GitHub

Проект уже содержит все необходимые файлы:

```
islam-education-portal/
├── .github/workflows/       # GitHub Actions (создайте при необходимости)
├── .gitignore              # Список игнорируемых файлов
├── .dockerignore           # Список игнорируемых Docker файлов
├── .env.example            # Пример переменных окружения
├── README.md               # Основная документация
├── DEPLOY_GUIDE.md         # Подробное руководство по развертыванию
├── GITHUB_SETUP.md         # Этот файл
├── docker-compose.yml      # Конфигурация Docker Compose
├── deploy.sh               # Скрипт быстрого развертывания
├── production-setup.sh     # Скрипт настройки production
├── backup.sh               # Скрипт резервного копирования
├── monitor.sh              # Скрипт мониторинга
├── get-ssl-cert.sh         # Скрипт получения SSL сертификата
├── mongo-init.js           # Инициализация MongoDB
├── backend/                # Backend приложение
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── server.py
│   ├── models.py
│   └── ...
├── frontend/               # Frontend приложение
│   ├── Dockerfile
│   ├── package.json
│   ├── src/
│   └── ...
├── nginx/                  # Конфигурация Nginx
│   ├── nginx.conf
│   └── ssl/
└── uploads/                # Папка для загрузок
```

## Клонирование с GitHub

После загрузки на GitHub, другие пользователи смогут развернуть проект:

```bash
# Клонирование репозитория
git clone https://github.com/YOUR_USERNAME/islam-education-portal.git
cd islam-education-portal

# Быстрое развертывание
chmod +x deploy.sh
./deploy.sh
```

## Обновление кода

Для обновления кода в будущем:

```bash
# Внесение изменений
git add .
git commit -m "Описание изменений"
git push origin main

# На сервере (если не используете GitHub Actions)
git pull origin main
docker-compose down
docker-compose up --build -d
```

## Создание релизов

Для создания релизов:

```bash
# Создание тега версии
git tag -a v1.0.0 -m "Первый релиз исламского образовательного портала"
git push origin v1.0.0
```

Затем на GitHub создайте Release из этого тега.

## Полезные команды Git

```bash
# Просмотр статуса
git status

# Просмотр истории коммитов
git log --oneline

# Отмена последнего коммита (без потери изменений)
git reset --soft HEAD~1

# Откат к определенному коммиту
git checkout COMMIT_HASH

# Создание новой ветки
git checkout -b feature/new-feature

# Слияние веток
git checkout main
git merge feature/new-feature
```

## Рекомендации по работе с GitHub

1. **Используйте осмысленные commit сообщения**:
   ```bash
   git commit -m "feat: добавлена система уведомлений"
   git commit -m "fix: исправлена ошибка в админ панели"
   git commit -m "docs: обновлена документация API"
   ```

2. **Создавайте ветки для новых функций**:
   ```bash
   git checkout -b feature/email-notifications
   # ... внесение изменений ...
   git commit -m "feat: добавлены email уведомления"
   git push origin feature/email-notifications
   # Создание Pull Request на GitHub
   ```

3. **Регулярно создавайте резервные копии**:
   ```bash
   # Создание дополнительного удаленного репозитория
   git remote add backup https://github.com/YOUR_USERNAME/islam-portal-backup.git
   git push backup main
   ```

4. **Используйте .gitignore для исключения чувствительных данных**:
   - Файлы .env с реальными паролями
   - Загруженные пользователями файлы
   - Логи и кеш
   - SSL сертификаты

---

**Успешной работы с GitHub! 🚀**

После загрузки проекта на GitHub, не забудьте:
1. Обновить ссылки в README.md
2. Добавить описание проекта
3. Настроить GitHub Pages для документации (если нужно)
4. Создать Issues для планирования новых функций
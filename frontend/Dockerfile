FROM node:18-alpine

WORKDIR /app

# Копирование package.json и yarn.lock
COPY package*.json yarn.lock ./

# Установка зависимостей
RUN yarn install --frozen-lockfile

# Копирование исходного кода
COPY . .

# Аргументы для сборки
ARG REACT_APP_BACKEND_URL
ENV REACT_APP_BACKEND_URL=$REACT_APP_BACKEND_URL

# Сборка приложения
RUN yarn build

# Использование nginx для обслуживания
FROM nginx:alpine
COPY --from=0 /app/build /usr/share/nginx/html

# Копирование конфигурации nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
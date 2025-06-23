// Инициализация базы данных MongoDB
db = db.getSiblingDB('islam_education');

// Создание коллекций
db.createCollection('users');
db.createCollection('courses');
db.createCollection('lessons');
db.createCollection('tests');
db.createCollection('qa_questions');
db.createCollection('team_members');

// Создание администратора
db.users.insertOne({
  "id": "admin-user-id",
  "username": "admin",
  "email": "admin@islam-education.com",
  "password": "$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW", // Пароль: admin123
  "is_admin": true,
  "full_name": "Администратор",
  "created_at": new Date(),
  "updated_at": new Date()
});

console.log('База данных islam_education инициализирована');
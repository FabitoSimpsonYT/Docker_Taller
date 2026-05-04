-- Script de inicialización para MariaDB
-- Este archivo se ejecuta automáticamente al iniciar el contenedor

USE pern_db;

-- Crear tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email)
);

-- Crear tabla de posts/artículos
CREATE TABLE IF NOT EXISTS posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content LONGTEXT,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);

-- Crear tabla de comentarios
CREATE TABLE IF NOT EXISTS comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  content TEXT NOT NULL,
  user_id INT NOT NULL,
  post_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  INDEX idx_post_id (post_id),
  INDEX idx_user_id (user_id)
);

-- Insertar datos de prueba
INSERT INTO users (name, email, password) VALUES 
('Juan Pérez', 'juan@example.com', 'hashed_password_1'),
('María García', 'maria@example.com', 'hashed_password_2'),
('Carlos López', 'carlos@example.com', 'hashed_password_3');

INSERT INTO posts (title, content, user_id) VALUES 
('Mi primer post', 'Este es el contenido del primer post', 1),
('Segundo artículo', 'Aquí va el contenido del segundo artículo', 2),
('Tercer post', 'Contenido del tercer post', 1);

INSERT INTO comments (content, user_id, post_id) VALUES 
('Excelente post!', 2, 1),
('Muy interesante', 3, 1),
('Gracias por compartir', 1, 2);

-- Ver el resultado
SELECT 'Inicialización completada' AS status;

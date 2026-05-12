-- Script de inicialización para PostgreSQL
-- Este archivo se ejecuta automáticamente al iniciar el contenedor

-- Crear tabla de usuarios
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear índice en email
CREATE INDEX IF NOT EXISTS idx_email ON users(email);

-- Crear tabla de posts/artículos
CREATE TABLE IF NOT EXISTS posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Crear índice en user_id
CREATE INDEX IF NOT EXISTS idx_post_user_id ON posts(user_id);

-- Crear tabla de comentarios
CREATE TABLE IF NOT EXISTS comments (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  user_id INT NOT NULL,
  post_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);

-- Crear índices en comments
CREATE INDEX IF NOT EXISTS idx_comment_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comment_user_id ON comments(user_id);

-- Insertar datos de prueba
INSERT INTO users (name, email, password) VALUES 
('Juan Pérez', 'juan@example.com', 'hashed_password_1'),
('María García', 'maria@example.com', 'hashed_password_2'),
('Carlos López', 'carlos@example.com', 'hashed_password_3')
ON CONFLICT (email) DO NOTHING;

INSERT INTO posts (title, content, user_id) VALUES 
('Mi primer post', 'Este es el contenido del primer post', 1),
('Segundo artículo', 'Aquí va el contenido del segundo artículo', 2),
('Tercer post', 'Contenido del tercer post', 1)
ON CONFLICT DO NOTHING;

INSERT INTO comments (content, user_id, post_id) VALUES 
('Excelente post!', 2, 1),
('Muy interesante', 3, 1),
('Gracias por compartir', 1, 2)
ON CONFLICT DO NOTHING;

-- Ver el resultado
SELECT 'Inicialización completada' AS status;

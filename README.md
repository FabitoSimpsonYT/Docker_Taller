# Stack PERN con MariaDB - Docker

Este proyecto proporciona una configuración completa de Docker para un stack PERN (PostgreSQL → MariaDB, Express, React, Node.js).

## Estructura del Proyecto

```
.
├── Dockerfile.backend          # Dockerfile para Node.js/Express
├── Dockerfile.frontend         # Dockerfile para React
├── docker-compose.yml          # Orquestación de servicios
├── nginx.conf                  # Configuración de Nginx
├── .dockerignore              # Archivos a ignorar en build
├── .env.example               # Variables de entorno de ejemplo
├── package.backend.json       # Dependencias backend
├── package.frontend.json      # Dependencias frontend
├── server.example.js          # Servidor Express de ejemplo
└── scripts/                   # Scripts SQL de inicialización
```

## Requisitos

- Docker (v20.10+)
- Docker Compose (v2.0+)

## Estructura de Carpetas Necesaria

```
Docker_Taller/
├── backend/
│   ├── package.json
│   ├── server.js
│   └── node_modules/
├── frontend/
│   ├── package.json
│   ├── public/
│   ├── src/
│   └── node_modules/
└── scripts/
    └── init.sql (opcional)
```

## Configuración Rápida

### 1. Preparar el proyecto

```bash
# Clonar o crear la estructura de carpetas
mkdir -p backend frontend scripts

# Copiar los archivos de ejemplo
cp package.backend.json backend/package.json
cp package.frontend.json frontend/package.json
cp server.example.js backend/server.js
```

### 2. Crear archivo de variables de entorno

```bash
cp .env.example .env
```

### 3. Iniciar los servicios

```bash
# Construcción e inicio en background
docker-compose up -d

# O con logs en tiempo real
docker-compose up

# Construcción y inicio sin caché
docker-compose up --build
```

## Acceso a los Servicios

- **Frontend (React)**: http://localhost:80
- **Backend (Express)**: http://localhost:5000
- **MariaDB**: localhost:3306

Credenciales MariaDB por defecto:
- Usuario: `pern_user`
- Contraseña: `pern_password`
- Base de datos: `pern_db`
- Root password: `root_password`

## Comandos Útiles

### Ver estado de los contenedores
```bash
docker-compose ps
```

### Ver logs en tiempo real
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mariadb
```

### Ejecutar comando en un contenedor
```bash
docker-compose exec backend npm install
docker-compose exec frontend npm install
```

### Entrar a la base de datos
```bash
docker-compose exec mariadb mysql -u pern_user -p pern_db
```

### Detener servicios
```bash
docker-compose stop
```

### Eliminar todo
```bash
docker-compose down -v  # -v elimina también los volúmenes
```

## Scripts de Inicialización SQL

Coloca archivos `.sql` en la carpeta `scripts/` para ejecutarlos automáticamente al iniciar MariaDB.

Ejemplo `scripts/init.sql`:
```sql
USE pern_db;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES 
('Usuario Test', 'test@example.com');
```

## Optimizaciones Incluidas

✅ **Multi-stage builds** - Optimiza el tamaño de las imágenes
✅ **Health checks** - Monitoreo automático de servicios
✅ **Volumes** - Persistencia de datos en MariaDB
✅ **Networking** - Comunicación segura entre servicios
✅ **Security headers** - Headers de seguridad en Nginx
✅ **Environment variables** - Configuración flexible

## Variables de Entorno

```
DB_HOST=mariadb              # Host de MariaDB
DB_PORT=3306                 # Puerto de MariaDB
DB_NAME=pern_db              # Nombre de la base de datos
DB_USER=pern_user            # Usuario de la BD
DB_PASSWORD=pern_password    # Contraseña de la BD
NODE_ENV=production          # Entorno (production/development)
API_PORT=5000                # Puerto del backend
REACT_APP_API_URL=http://localhost:5000  # URL de la API para React
```

## Troubleshooting

### La base de datos no se conecta
```bash
docker-compose down -v
docker-compose up --build
```

### Puerto ya en uso
Cambia los puertos en `docker-compose.yml`:
```yaml
ports:
  - "3307:3306"  # Cambiar primer número
  - "5001:5000"  # Cambiar primer número
```

### Ver logs de error
```bash
docker-compose logs --tail=100 backend
```

## Desarrollo Local

Para desarrollo sin Docker:

```bash
# Backend
cd backend
npm install
npm run dev

# Frontend (en otra terminal)
cd frontend
npm install
npm start

# MariaDB con tu cliente preferido
```

## Producción

Para producción, considera:

1. Usar variables de entorno seguras
2. Habilitar HTTPS en Nginx
3. Agregar autenticación a MariaDB
4. Usar image registry privado
5. Configurar backup automático de BD
6. Agregar monitoring y logging

---

**Hecho para Docker Taller** 🐳
# Mejores Prácticas y Troubleshooting

## 🚀 Mejores Prácticas

### 1. Gestión de Variables de Entorno

**✓ CORRECTO:**
```bash
# Crear .env basado en .env.example
cp .env.example .env

# Usar valores seguros en producción
DB_ROOT_PASSWORD=TuContraseñaSeguraAqui123!@
DB_PASSWORD=OtraContraseña456!@#
```

**✗ INCORRECTO:**
```bash
# No hardcodear passwords en docker-compose.yml
# No usar "password" o "123456" en producción
# No pushear .env a git
```

### 2. Volúmenes

**✓ CORRECTO:**
```yaml
# Desarrollo - bind mount para hot reload
backend:
  volumes:
    - ./backend:/app
    - /app/node_modules  # No sincronizar node_modules

# Producción - named volumes
volumes:
  - mariadb_prod_data:/var/lib/mysql
```

**✗ INCORRECTO:**
```yaml
# No sincronizar node_modules
- ./backend:/app  # Esto sobrescribe node_modules

# No usar bind mounts en producción
- ./code:/app  # Seguridad débil
```

### 3. Health Checks

**✓ CORRECTO:**
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

**✗ INCORRECTO:**
```yaml
# Sin health checks
# Sin start_period (importante para DB)
# Retries muy bajo
```

### 4. Redes

**✓ CORRECTO:**
```yaml
networks:
  - pern_network

# Servicios se comunican por hostname (mariadb, backend)
```

**✗ INCORRECTO:**
```bash
# Usar localhost en contenedores
services:
  backend:
    DB_HOST: localhost  # NO! Usar 'mariadb'
```

### 5. Seguridad

**✓ CORRECTO:**
```yaml
# No exponer puertos internos
backend:
  expose:  # Solo interna
    - "5000"
  # NO ports en producción si tienes load balancer

# Health checks sin logs sensibles
# Headers de seguridad en Nginx
# Secrets en Docker Secrets (não en env files)
```

**✗ INCORRECTO:**
```yaml
# Exponer todos los puertos
mariadb:
  ports:
    - "3306:3306"  # En producción, solo en desarrollo

# Root password débil
MYSQL_ROOT_PASSWORD: "root"
```

### 6. Multi-stage Builds

**✓ CORRECTO:**
```dockerfile
FROM node:18-alpine AS builder
RUN npm ci

FROM node:18-alpine
COPY --from=builder /app/node_modules ./node_modules
```

**✗ INCORRECTO:**
```dockerfile
# Imagen grande sin optimizar
FROM node:18
RUN npm ci
# Todos los archivos de build quedan en la imagen
```

## 🐛 Troubleshooting

### Problema: "Cannot connect to the Docker daemon"

**Solución:**
```bash
# Iniciar Docker Desktop (Windows/Mac)
# O verificar que el daemon está corriendo (Linux)
sudo systemctl start docker

# En Windows (PowerShell):
wsl --list --verbose  # Verificar WSL 2
```

### Problema: "Port 3306 already in use"

**Solución:**
```bash
# Encontrar el proceso que usa el puerto
netstat -ano | findstr :3306  # Windows
lsof -i :3306                 # Mac/Linux

# Cambiar el puerto en docker-compose.yml
ports:
  - "3307:3306"  # Usar 3307 en local
```

### Problema: "MariaDB connection timed out"

**Solución:**
```bash
# Verificar que MariaDB está corriendo
docker-compose ps

# Ver logs
docker-compose logs mariadb

# Reiniciar la base de datos
docker-compose restart mariadb

# Limpiar y reconstruir
docker-compose down -v
docker-compose up --build
```

### Problema: "Backend no puede conectar a la BD"

**Causa común:** Usar `localhost` en lugar del nombre del servicio

**Solución:**
```javascript
// ✗ INCORRECTO
const sequelize = new Sequelize({
  host: 'localhost'  // NO! En Docker, 'localhost' es el contenedor mismo
});

// ✓ CORRECTO
const sequelize = new Sequelize({
  host: process.env.DB_HOST  // 'mariadb' (del docker-compose.yml)
});
```

### Problema: "Build context too large"

**Solución:**
```bash
# Verificar .dockerignore
cat .dockerignore

# Asegurarse de que node_modules esté ignorado
# node_modules está en .dockerignore? ✓

# Agregar más directorios
.git/
.gitignore
dist/
test/
docs/
```

### Problema: "npm install en el contenedor falla"

**Solución:**
```bash
# Limpiar cache npm
docker-compose exec backend npm cache clean --force

# Reinstalar dependencias
docker-compose exec backend npm install

# O reconstruir la imagen
docker-compose build --no-cache backend
```

### Problema: "Frontend no muestra cambios"

**Solución (desarrollo):**
```yaml
# Verificar que binding mount está correcto
backend:
  volumes:
    - ./frontend:/app          # ✓
    - /app/node_modules        # ✓ Importante!

# En development, usar:
docker-compose up  # Sin -d, ver logs en tiempo real
```

### Problema: "Base de datos no tiene datos"

**Solución:**
```bash
# Verificar que scripts/init.sql existe
ls scripts/

# Ver logs de inicialización
docker-compose logs mariadb

# Reiniciar con volumen limpio
docker-compose down -v
docker-compose up

# Verificar datos manualmente
docker-compose exec mariadb mysql -u pern_user -p pern_db -e "SELECT * FROM users;"
```

### Problema: "React compilación fallida"

**Solución:**
```bash
# Ver logs completos
docker-compose logs frontend

# Limpiar caché y rebuild
docker-compose exec frontend npm cache clean --force
docker-compose build --no-cache frontend

# Verificar que REACT_APP_API_URL está configurado
docker-compose exec frontend env | grep REACT_APP
```

## 📊 Monitoreo en Producción

### Ver uso de recursos
```bash
docker stats pern_backend
docker stats pern_frontend
docker stats pern_mariadb
```

### Ver logs persistentes
```bash
# Escribir logs en archivo
docker-compose logs backend > backend.log
docker-compose logs mariadb > mariadb.log
```

### Health check status
```bash
docker-compose ps

# Debería mostrar:
# Status: Up (healthy)
```

## 🔐 Seguridad en Producción

### 1. Contraseñas Fuertes
```bash
# Generar contraseña segura
openssl rand -base64 32
```

### 2. Usar Secrets de Docker
```bash
# En lugar de .env
docker secret create db_password -
```

### 3. HTTPS/TLS
```nginx
# En nginx.conf
server {
    listen 443 ssl;
    ssl_certificate /etc/nginx/cert.pem;
    ssl_certificate_key /etc/nginx/key.pem;
```

### 4. Firewall
```bash
# Solo exponer puertos necesarios
# 80 (HTTP)
# 443 (HTTPS)
# No exponer 3306, 5000 a internet
```

### 5. Backups de BD
```bash
docker-compose exec mariadb mysqldump -u pern_user -p pern_db > backup.sql
```

## 📈 Análisis de Rendimiento

### Query lenta?
```sql
EXPLAIN SELECT * FROM posts WHERE user_id = 1;

-- Agregar índice si falta
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

### Memoria alta?
```bash
# Ver consumo
docker stats pern_backend

# Aumentar límites en docker-compose.yml
deploy:
  resources:
    limits:
      memory: 512M
```

### CPU alta?
```bash
# Ver procesos en el contenedor
docker-compose exec backend top
docker-compose exec mariadb top
```

## 🧹 Limpieza y Mantenimiento

### Liberar espacio
```bash
# Eliminar contenedores parados
docker container prune

# Eliminar imágenes no usadas
docker image prune

# Eliminar volúmenes no usados
docker volume prune

# Todo (WARNING: destructivo)
docker system prune -a --volumes
```

### Actualizar imágenes base
```bash
# Actualizar Node.js
node:18-alpine → node:20-alpine

# Reconstruir
docker-compose build --no-cache
```

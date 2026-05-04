# Arquitectura - Stack PERN con MariaDB

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                           USUARIO FINAL                             │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
         ┌───────────────────────────────────────────────┐
         │                                               │
         │     FRONTEND (React + Nginx)                  │
         │     Puerto: 80                                │
         │     Container: pern_frontend                  │
         │                                               │
         │  • React SPA (Single Page Application)        │
         │  • Build multi-stage con Node.js              │
         │  • Nginx como servidor HTTP                   │
         │  • Proxy reverso a /api/                      │
         │                                               │
         └────────────────┬────────────────────────────┘
                          │ HTTP (puerto 80)
                          │ Proxy: /api/ → backend:5000
                          ▼
         ┌───────────────────────────────────────────────┐
         │                                               │
         │     BACKEND (Node.js + Express)               │
         │     Puerto: 5000                              │
         │     Container: pern_backend                   │
         │                                               │
         │  • Express.js API REST                        │
         │  • Conexión a MariaDB con Sequelize           │
         │  • Health checks                              │
         │  • Middleware CORS                            │
         │                                               │
         └────────────────┬────────────────────────────┘
                          │ TCP (puerto 3306)
                          │ Driver: mysql2
                          ▼
         ┌───────────────────────────────────────────────┐
         │                                               │
         │     DATABASE (MariaDB)                        │
         │     Puerto: 3306                              │
         │     Container: pern_mariadb                   │
         │                                               │
         │  • MariaDB (compatible con MySQL)             │
         │  • Base de datos: pern_db                     │
         │  • Volumen persistente: mariadb_data          │
         │  • Usuario: pern_user                         │
         │                                               │
         └───────────────────────────────────────────────┘
```

## Red de Docker

```
   pern_network (Bridge Network)
   ├─ Frontend (pern_frontend)
   ├─ Backend (pern_backend)
   └─ Database (pern_mariadb)
```

## Flujo de Datos

### 1. Request del Cliente

```
Usuario Browser
     │
     ├─ GET http://localhost:80/
     │
     └─→ Nginx (Frontend)
         ├─ Sirve archivos estáticos (React bundle)
         └─ Redirige /api/ → Backend
```

### 2. Request de API

```
React App
     │
     ├─ GET/POST http://localhost:5000/api/users
     │
     └─→ Express Backend
         ├─ Procesa request
         ├─ Query a MariaDB
         └─ Retorna JSON
```

### 3. Acceso a Base de Datos

```
Express Backend
     │
     ├─ Sequelize ORM
     │
     └─→ MariaDB Driver (mysql2)
         ├─ Conexión TCP
         ├─ Ejecuta queries SQL
         └─ Retorna datos
```

## Volúmenes

| Nombre | Contenedor | Ruta | Propósito |
|--------|-----------|------|----------|
| `mariadb_data` | MariaDB | `/var/lib/mysql` | Persistencia de datos |
| Bind Mount | Backend | `/app` | Código fuente (desarrollo) |
| Bind Mount | Frontend | `/app` | Código fuente (desarrollo) |

## Variables de Entorno

### Backend
```
NODE_ENV=production
API_PORT=5000
DB_HOST=mariadb
DB_PORT=3306
DB_NAME=pern_db
DB_USER=pern_user
DB_PASSWORD=pern_password
```

### Frontend
```
REACT_APP_API_URL=http://backend:5000
```

### MariaDB
```
MYSQL_ROOT_PASSWORD=root_password
MYSQL_DATABASE=pern_db
MYSQL_USER=pern_user
MYSQL_PASSWORD=pern_password
```

## Health Checks

Cada servicio incluye health checks automáticos:

### Backend
```bash
GET http://localhost:5000/health
# Retorna: {"status": "OK", "message": "Backend is running"}
```

### Frontend
```bash
GET http://localhost:80/health
# Retorna: "healthy"
```

### MariaDB
```bash
mysqladmin ping -h localhost
# Retorna: mysqld is alive
```

## Dependencias de Servicios

```
Frontend ──────┐
               ├──→ Backend ──→ MariaDB
Backend ───────┘
```

- **Frontend** depende de: Backend (para API)
- **Backend** depende de: MariaDB (para datos)
- **MariaDB** no depende de nada

## Seguridad

### Network Isolation
- Los servicios se comunican por red privada `pern_network`
- No exponen puertos internos

### Puertos Expostos
- Solo Frontend (80), Backend (5000) y MariaDB (3306)
- Los demás puertos quedan privados

### Headers de Seguridad
```
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
```

## Escalabilidad Potencial

### Horizontal Scaling
```yaml
# Múltiples instancias del backend
backend-1:
  ...
backend-2:
  ...
backend-3:
  ...
  
# Load balancer (Nginx/HAProxy)
load-balancer:
  ...
```

### Caché
```yaml
# Redis para caché
redis:
  image: redis:alpine
  ports:
    - "6379:6379"
```

### Message Queue
```yaml
# RabbitMQ para procesos asíncronos
rabbitmq:
  image: rabbitmq:alpine
  ports:
    - "5672:5672"
```

## Performance Tuning

### Backend
- Connection pooling (Sequelize pool)
- Índices en MariaDB
- Compression middleware
- Caching headers

### Frontend
- Multi-stage build para reducir tamaño
- Gzip compression en Nginx
- Cache busting para JS/CSS

### Database
- Índices en columnas frecuentes
- Connection pooling
- Query optimization

## Desarrollo vs Producción

### Desarrollo
```bash
docker-compose -f docker-compose.yml up
# Con hot reload y logs visibles
```

### Producción
```bash
docker-compose -f docker-compose.prod.yml up -d
# Con healthchecks estrictos
# Sin bind mounts de código
# Variables seguras
```

## Monitoreo

### Logs
```bash
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f mariadb
```

### Métricas
- Container stats: `docker stats`
- Health status: `docker-compose ps`

### Debugging
- Shell en container: `docker-compose exec service sh`
- Inspect container: `docker inspect container_name`

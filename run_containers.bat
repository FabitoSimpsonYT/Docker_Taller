@echo off
REM Script para ejecutar los 3 contenedores Docker en paralelo sin docker-compose
REM Backend, Frontend y PostgreSQL

setlocal enabledelayedexpansion

echo ===============================================
echo Iniciando servicios Docker en paralelo
echo ===============================================

REM Definir variables
set NETWORK_NAME=pern_network
set DB_CONTAINER=pern_postgres
set BACKEND_CONTAINER=pern_backend
set FRONTEND_CONTAINER=pern_frontend
set DB_PORT=5432
set BACKEND_PORT=5000
set FRONTEND_PORT=80

REM Colores para output (usando códigos ANSI en Windows 10+)
setlocal
for /F %%A in ('echo prompt $H ^| cmd') do set "BS=%%A"

echo.
echo [1] Creando red Docker personalizada...
docker network create %NETWORK_NAME% 2>nul
if %errorlevel% equ 0 (
    echo    ✓ Red '%NETWORK_NAME%' creada
) else (
    echo    ! Red '%NETWORK_NAME%' ya existe
)

echo.
echo [2] Compilando imagen de PostgreSQL...
docker build -t pern-postgres:latest -f Dockerfile.postgres .
if %errorlevel% neq 0 (
    echo    ✗ Error al compilar PostgreSQL
    exit /b 1
)
echo    ✓ PostgreSQL compilado

echo.
echo [3] Iniciando contenedor PostgreSQL...
docker run -d ^
  --name %DB_CONTAINER% ^
  --network %NETWORK_NAME% ^
  -p %DB_PORT%:5432 ^
  -e POSTGRES_DB=pern_db ^
  -e POSTGRES_USER=pern_user ^
  -e POSTGRES_PASSWORD=pern_password ^
  -v postgres_data:/var/lib/postgresql/data ^
  --health-cmd="pg_isready -U pern_user -d pern_db" ^
  --health-interval=10s ^
  --health-timeout=5s ^
  --health-start-period=10s ^
  --health-retries=5 ^
  pern-postgres:latest
if %errorlevel% neq 0 (
    echo    ✗ Error al iniciar PostgreSQL
    exit /b 1
)
echo    ✓ PostgreSQL iniciado

echo.
echo [4] Esperando a que PostgreSQL esté listo...
timeout /t 5 /nobreak

echo.
echo [5] Compilando imagen del Backend...
docker build -t pern-backend:latest -f Dockerfile.backend ./backend
if %errorlevel% neq 0 (
    echo    ✗ Error al compilar Backend
    exit /b 1
)
echo    ✓ Backend compilado

echo.
echo [6] Iniciando contenedor Backend...
docker run -d ^
  --name %BACKEND_CONTAINER% ^
  --network %NETWORK_NAME% ^
  -p %BACKEND_PORT%:5000 ^
  -e NODE_ENV=production ^
  -e DB_HOST=pern_postgres ^
  -e DB_PORT=5432 ^
  -e DB_NAME=pern_db ^
  -e DB_USER=pern_user ^
  -e DB_PASSWORD=pern_password ^
  -e API_PORT=5000 ^
  --health-cmd="curl -f http://localhost:5000/health ^| ^| exit 1" ^
  --health-interval=30s ^
  --health-timeout=10s ^
  --health-start-period=5s ^
  --health-retries=3 ^
  pern-backend:latest
if %errorlevel% neq 0 (
    echo    ✗ Error al iniciar Backend
    exit /b 1
)
echo    ✓ Backend iniciado

echo.
echo [7] Compilando imagen del Frontend...
docker build -t pern-frontend:latest -f Dockerfile.frontend ./frontend
if %errorlevel% neq 0 (
    echo    ✗ Error al compilar Frontend
    exit /b 1
)
echo    ✓ Frontend compilado

echo.
echo [8] Iniciando contenedor Frontend...
docker run -d ^
  --name %FRONTEND_CONTAINER% ^
  --network %NETWORK_NAME% ^
  -p %FRONTEND_PORT%:80 ^
  -e REACT_APP_API_URL=http://localhost:5000 ^
  --health-cmd="wget --quiet --tries=1 --spider http://localhost/health ^| ^| exit 1" ^
  --health-interval=30s ^
  --health-timeout=10s ^
  --health-start-period=5s ^
  --health-retries=3 ^
  pern-frontend:latest
if %errorlevel% neq 0 (
    echo    ✗ Error al iniciar Frontend
    exit /b 1
)
echo    ✓ Frontend iniciado

echo.
echo ===============================================
echo ✓ Todos los servicios iniciados correctamente
echo ===============================================
echo.
echo URLs de acceso:
echo   Frontend:  http://localhost:%FRONTEND_PORT%
echo   Backend:   http://localhost:%BACKEND_PORT%
echo   Database:  localhost:%DB_PORT%
echo.
echo Contenedores activos:
docker ps --filter "network=%NETWORK_NAME%" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
echo Para detener los servicios, ejecuta: stop_containers.bat
echo.

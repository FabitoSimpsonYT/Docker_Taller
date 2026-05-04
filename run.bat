@echo off
REM Script de ayuda para el Docker Taller - Stack PERN con MariaDB

if "%1"=="" goto help

if /i "%1"=="start" (
    echo Iniciando servicios...
    docker-compose up -d
    echo Servicios iniciados
    docker-compose ps
    goto end
)

if /i "%1"=="stop" (
    echo Deteniendo servicios...
    docker-compose stop
    echo Servicios detenidos
    goto end
)

if /i "%1"=="restart" (
    echo Reiniciando servicios...
    docker-compose restart
    echo Servicios reiniciados
    docker-compose ps
    goto end
)

if /i "%1"=="logs" (
    echo Mostrando logs (Presiona Ctrl+C para salir)...
    docker-compose logs -f
    goto end
)

if /i "%1"=="logs-backend" (
    echo Logs del Backend...
    docker-compose logs -f backend
    goto end
)

if /i "%1"=="logs-frontend" (
    echo Logs del Frontend...
    docker-compose logs -f frontend
    goto end
)

if /i "%1"=="logs-db" (
    echo Logs de la Base de Datos...
    docker-compose logs -f mariadb
    goto end
)

if /i "%1"=="build" (
    echo Reconstruyendo imágenes...
    docker-compose build --no-cache
    echo Imágenes reconstruidas
    goto end
)

if /i "%1"=="ps" (
    echo Estado de los servicios...
    docker-compose ps
    goto end
)

if /i "%1"=="clean" (
    echo Limpiando contenedores y volúmenes...
    docker-compose down -v
    echo Limpieza completada
    goto end
)

if /i "%1"=="db-shell" (
    echo Conectando a MariaDB...
    docker-compose exec mariadb mysql -u pern_user -p pern_db
    goto end
)

if /i "%1"=="db-root" (
    echo Conectando a MariaDB como root...
    docker-compose exec mariadb mysql -u root -p
    goto end
)

if /i "%1"=="backend-shell" (
    echo Shell en Backend...
    docker-compose exec backend sh
    goto end
)

if /i "%1"=="frontend-shell" (
    echo Shell en Frontend...
    docker-compose exec frontend sh
    goto end
)

if /i "%1"=="install-deps" (
    echo Instalando dependencias del Backend...
    docker-compose exec backend npm install
    echo Backend listo
    echo Instalando dependencias del Frontend...
    docker-compose exec frontend npm install
    echo Frontend listo
    goto end
)

:help
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║   Docker Taller - Stack PERN con MariaDB                      ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Uso: run.bat [comando]
echo.
echo Comandos disponibles:
echo   start              - Iniciar todos los servicios
echo   stop               - Detener todos los servicios
echo   restart            - Reiniciar todos los servicios
echo   build              - Reconstruir las imágenes Docker
echo   ps                 - Ver estado de los servicios
echo   logs               - Ver logs de todos los servicios
echo   logs-backend       - Ver logs del backend
echo   logs-frontend      - Ver logs del frontend
echo   logs-db            - Ver logs de la base de datos
echo   clean              - Eliminar contenedores y volúmenes
echo   db-shell           - Acceder a la terminal de MariaDB
echo   db-root            - Acceder como root a MariaDB
echo   backend-shell      - Acceder a la terminal del backend
echo   frontend-shell     - Acceder a la terminal del frontend
echo   install-deps       - Instalar dependencias npm
echo.
echo Acceso a servicios:
echo   Frontend:  http://localhost:80
echo   Backend:   http://localhost:5000
echo   MariaDB:   localhost:3306
echo            Usuario: pern_user
echo            Contrasena: pern_password
echo.

:end

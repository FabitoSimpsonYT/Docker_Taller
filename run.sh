#!/bin/bash

# Script de ayuda para el Docker Taller - Stack PERN con MariaDB

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   Docker Taller - Stack PERN con MariaDB                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

case "${1:-help}" in
  start)
    echo "▶ Iniciando servicios..."
    docker-compose up -d
    echo "✓ Servicios iniciados"
    docker-compose ps
    ;;
  
  stop)
    echo "▶ Deteniendo servicios..."
    docker-compose stop
    echo "✓ Servicios detenidos"
    ;;
  
  restart)
    echo "▶ Reiniciando servicios..."
    docker-compose restart
    echo "✓ Servicios reiniciados"
    docker-compose ps
    ;;
  
  logs)
    echo "▶ Mostrando logs (Press Ctrl+C para salir)..."
    docker-compose logs -f
    ;;
  
  logs-backend)
    echo "▶ Logs del Backend..."
    docker-compose logs -f backend
    ;;
  
  logs-frontend)
    echo "▶ Logs del Frontend..."
    docker-compose logs -f frontend
    ;;
  
  logs-db)
    echo "▶ Logs de la Base de Datos..."
    docker-compose logs -f mariadb
    ;;
  
  build)
    echo "▶ Reconstruyendo imágenes..."
    docker-compose build --no-cache
    echo "✓ Imágenes reconstruidas"
    ;;
  
  ps)
    echo "▶ Estado de los servicios..."
    docker-compose ps
    ;;
  
  clean)
    echo "▶ Limpiando contenedores y volúmenes..."
    docker-compose down -v
    echo "✓ Limpieza completada"
    ;;
  
  db-shell)
    echo "▶ Conectando a MariaDB..."
    docker-compose exec mariadb mysql -u pern_user -p pern_db
    ;;
  
  db-root)
    echo "▶ Conectando a MariaDB como root..."
    docker-compose exec mariadb mysql -u root -p
    ;;
  
  backend-shell)
    echo "▶ Shell en Backend..."
    docker-compose exec backend sh
    ;;
  
  frontend-shell)
    echo "▶ Shell en Frontend..."
    docker-compose exec frontend sh
    ;;
  
  install-deps)
    echo "▶ Instalando dependencias del Backend..."
    docker-compose exec backend npm install
    echo "✓ Backend listo"
    echo "▶ Instalando dependencias del Frontend..."
    docker-compose exec frontend npm install
    echo "✓ Frontend listo"
    ;;
  
  *)
    echo "Uso: $0 {comando}"
    echo ""
    echo "Comandos disponibles:"
    echo "  start              - Iniciar todos los servicios"
    echo "  stop               - Detener todos los servicios"
    echo "  restart            - Reiniciar todos los servicios"
    echo "  build              - Reconstruir las imágenes Docker"
    echo "  ps                 - Ver estado de los servicios"
    echo "  logs               - Ver logs de todos los servicios"
    echo "  logs-backend       - Ver logs del backend"
    echo "  logs-frontend      - Ver logs del frontend"
    echo "  logs-db            - Ver logs de la base de datos"
    echo "  clean              - Eliminar contenedores y volúmenes"
    echo "  db-shell           - Acceder a la terminal de MariaDB"
    echo "  db-root            - Acceder como root a MariaDB"
    echo "  backend-shell      - Acceder a la terminal del backend"
    echo "  frontend-shell     - Acceder a la terminal del frontend"
    echo "  install-deps       - Instalar dependencias npm"
    echo ""
    echo "Acceso a servicios:"
    echo "  Frontend:  http://localhost:80"
    echo "  Backend:   http://localhost:5000"
    echo "  MariaDB:   localhost:3306"
    echo "            User: pern_user"
    echo "            Pass: pern_password"
    ;;
esac

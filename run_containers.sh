#!/bin/bash

# Script para ejecutar los 3 contenedores Docker en paralelo sin docker-compose
# Backend, Frontend y PostgreSQL

set -e

# Definir variables
NETWORK_NAME="pern_network"
DB_CONTAINER="pern_postgres"
BACKEND_CONTAINER="pern_backend"
FRONTEND_CONTAINER="pern_frontend"
DB_PORT=5432
BACKEND_PORT=5000
FRONTEND_PORT=80

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "==============================================="
echo "Iniciando servicios Docker en paralelo"
echo "==============================================="
echo

echo -e "[1] Creando red Docker personalizada..."
docker network create $NETWORK_NAME 2>/dev/null || echo -e "    ${YELLOW}!${NC} Red '$NETWORK_NAME' ya existe"
echo -e "    ${GREEN}✓${NC} Red '$NETWORK_NAME' lista"

echo
echo -e "[2] Compilando imagen de PostgreSQL..."
docker build -t pern-postgres:latest -f Dockerfile.postgres .
echo -e "    ${GREEN}✓${NC} PostgreSQL compilado"

echo
echo -e "[3] Iniciando contenedor PostgreSQL..."
docker run -d \
  --name $DB_CONTAINER \
  --network $NETWORK_NAME \
  -p $DB_PORT:5432 \
  -e POSTGRES_DB=pern_db \
  -e POSTGRES_USER=pern_user \
  -e POSTGRES_PASSWORD=pern_password \
  -v postgres_data:/var/lib/postgresql/data \
  --health-cmd="pg_isready -U pern_user -d pern_db" \
  --health-interval=10s \
  --health-timeout=5s \
  --health-start-period=10s \
  --health-retries=5 \
  pern-postgres:latest
echo -e "    ${GREEN}✓${NC} PostgreSQL iniciado"

echo
echo -e "[4] Esperando a que PostgreSQL esté listo..."
sleep 5

echo
echo -e "[5] Compilando imagen del Backend..."
docker build -t pern-backend:latest -f Dockerfile.backend ./backend
echo -e "    ${GREEN}✓${NC} Backend compilado"

echo
echo -e "[6] Iniciando contenedor Backend..."
docker run -d \
  --name $BACKEND_CONTAINER \
  --network $NETWORK_NAME \
  -p $BACKEND_PORT:5000 \
  -e NODE_ENV=production \
  -e DB_HOST=pern_postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=pern_db \
  -e DB_USER=pern_user \
  -e DB_PASSWORD=pern_password \
  -e API_PORT=5000 \
  --health-cmd="curl -f http://localhost:5000/health || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-start-period=5s \
  --health-retries=3 \
  pern-backend:latest
echo -e "    ${GREEN}✓${NC} Backend iniciado"

echo
echo -e "[7] Compilando imagen del Frontend..."
docker build -t pern-frontend:latest -f Dockerfile.frontend ./frontend
echo -e "    ${GREEN}✓${NC} Frontend compilado"

echo
echo -e "[8] Iniciando contenedor Frontend..."
docker run -d \
  --name $FRONTEND_CONTAINER \
  --network $NETWORK_NAME \
  -p $FRONTEND_PORT:80 \
  -e REACT_APP_API_URL=http://localhost:5000 \
  --health-cmd="wget --quiet --tries=1 --spider http://localhost/ || exit 1" \
  --health-interval=30s \
  --health-timeout=10s \
  --health-start-period=5s \
  --health-retries=3 \
  pern-frontend:latest
echo -e "    ${GREEN}✓${NC} Frontend iniciado"

echo
echo "==============================================="
echo -e "${GREEN}✓ Todos los servicios iniciados correctamente${NC}"
echo "==============================================="
echo
echo "URLs de acceso:"
echo "  Frontend:  http://localhost:$FRONTEND_PORT"
echo "  Backend:   http://localhost:$BACKEND_PORT"
echo "  Database:  localhost:$DB_PORT"
echo
echo "Contenedores activos:"
docker ps --filter "network=$NETWORK_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo
echo "Para detener los servicios, ejecuta: ./stop_containers.sh"
echo

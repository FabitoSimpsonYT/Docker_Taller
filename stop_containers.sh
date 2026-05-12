#!/bin/bash

# Script para detener y limpiar los contenedores Docker

NETWORK_NAME="pern_network"
DB_CONTAINER="pern_postgres"
BACKEND_CONTAINER="pern_backend"
FRONTEND_CONTAINER="pern_frontend"

# Colores
GREEN='\033[0;32m'
NC='\033[0m'

echo "==============================================="
echo "Deteniendo servicios Docker"
echo "==============================================="
echo

echo "[1] Deteniendo Frontend..."
docker stop $FRONTEND_CONTAINER 2>/dev/null || true
docker rm $FRONTEND_CONTAINER 2>/dev/null || true

echo "[2] Deteniendo Backend..."
docker stop $BACKEND_CONTAINER 2>/dev/null || true
docker rm $BACKEND_CONTAINER 2>/dev/null || true

echo "[3] Deteniendo PostgreSQL..."
docker stop $DB_CONTAINER 2>/dev/null || true
docker rm $DB_CONTAINER 2>/dev/null || true

echo
echo "[4] Eliminando red Docker..."
docker network rm $NETWORK_NAME 2>/dev/null || true

echo
echo "==============================================="
echo -e "${GREEN}✓ Servicios detenidos y removidos${NC}"
echo "==============================================="
echo

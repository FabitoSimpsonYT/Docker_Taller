@echo off
REM Script para detener y limpiar los contenedores Docker

setlocal enabledelayedexpansion

echo ===============================================
echo Deteniendo servicios Docker
echo ===============================================

set NETWORK_NAME=pern_network
set DB_CONTAINER=pern_postgres
set BACKEND_CONTAINER=pern_backend
set FRONTEND_CONTAINER=pern_frontend

echo.
echo [1] Deteniendo Frontend...
docker stop %FRONTEND_CONTAINER% 2>nul
docker rm %FRONTEND_CONTAINER% 2>nul

echo [2] Deteniendo Backend...
docker stop %BACKEND_CONTAINER% 2>nul
docker rm %BACKEND_CONTAINER% 2>nul

echo [3] Deteniendo PostgreSQL...
docker stop %DB_CONTAINER% 2>nul
docker rm %DB_CONTAINER% 2>nul

echo.
echo [4] Eliminando red Docker...
docker network rm %NETWORK_NAME% 2>nul

echo.
echo ===============================================
echo ✓ Servicios detenidos y removidos
echo ===============================================
echo.

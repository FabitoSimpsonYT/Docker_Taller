# PostgreSQL Database
FROM postgres:16-alpine

# Establecer variables de entorno
ENV POSTGRES_DB=pern_db
ENV POSTGRES_USER=pern_user
ENV POSTGRES_PASSWORD=pern_password

# Copiar scripts de inicialización (cuando está dentro de scripts/)
COPY init.sql /docker-entrypoint-initdb.d/

# Exponer puerto
EXPOSE 5432

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 \
  CMD pg_isready -U $POSTGRES_USER -d $POSTGRES_DB || exit 1

# Comando por defecto (postgres)
CMD ["postgres"]

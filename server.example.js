const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Sequelize } = require('sequelize');

dotenv.config();

const app = express();
const PORT = process.env.API_PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Configurar Sequelize para MariaDB
const sequelize = new Sequelize(
  process.env.DB_NAME || 'pern_db',
  process.env.DB_USER || 'pern_user',
  process.env.DB_PASSWORD || 'pern_password',
  {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);

// Rutas de Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Backend is running' });
});

// Ruta de prueba
app.get('/api/test', (req, res) => {
  res.json({ message: 'API funcionando correctamente' });
});

// Probar conexión a la base de datos
async function testDataBase() {
  try {
    await sequelize.authenticate();
    console.log('✓ Conexión a MariaDB establecida correctamente');
  } catch (error) {
    console.error('✗ Error al conectar a MariaDB:', error.message);
    process.exit(1);
  }
}

// Iniciar servidor
async function startServer() {
  try {
    await testDataBase();
    
    app.listen(PORT, () => {
      console.log(`🚀 Servidor running en puerto ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
}

startServer();

module.exports = app;

const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'mysql',
  logging: false, // Set to console.log to see SQL queries
  define: {
    timestamps: true,
    underscored: true,
  },
  pool: {
    max: 5,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
});

// Import model definitions
const defineUser = require('./user');

// Initialize models
const User = defineUser(sequelize);

// Export models and sequelize instance
module.exports = {
  sequelize,
  Sequelize,
  User
}; 
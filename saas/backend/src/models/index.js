const sequelize = require('../config/database');
const User = require('./user')(sequelize);

// Export models and sequelize instance
module.exports = {
  sequelize,
  User
}; 
const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true
      }
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    companyName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    role: {
      type: DataTypes.ENUM('admin', 'user'),
      defaultValue: 'user'
    }
  }, {
    tableName: 'users',
    timestamps: true,
    hooks: {
      beforeCreate: async (user) => {
        try {
          if (user.password) {
            user.password = await bcrypt.hash(user.password, 10);
          }
        } catch (error) {
          console.error('Error hashing password:', error);
          throw error;
        }
      },
      beforeUpdate: async (user) => {
        try {
          if (user.changed('password')) {
            user.password = await bcrypt.hash(user.password, 10);
          }
        } catch (error) {
          console.error('Error hashing password:', error);
          throw error;
        }
      }
    }
  });

  User.prototype.validatePassword = async function(password) {
    try {
      return bcrypt.compare(password, this.password);
    } catch (error) {
      console.error('Error validating password:', error);
      throw error;
    }
  };

  return User;
}; 
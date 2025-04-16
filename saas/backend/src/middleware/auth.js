const jwt = require('jsonwebtoken');
const { User } = require('../models');

const auth = async (req, res, next) => {
  try {
    console.log('Auth middleware - Headers:', req.headers);
    
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      console.log('No token provided');
      return res.status(401).json({ 
        success: false,
        message: 'Authentication required' 
      });
    }

    console.log('Token received:', token.substring(0, 10) + '...');
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key');
    console.log('Token decoded:', { id: decoded.id, email: decoded.email });

    const user = await User.findByPk(decoded.id);
    
    if (!user) {
      console.log('User not found for token');
      return res.status(401).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    req.user = user;
    req.token = token;
    
    console.log('Authentication successful for user:', user.id);
    next();
  } catch (error) {
    console.error('Auth middleware error:', {
      error: error.message,
      stack: error.stack
    });
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        success: false,
        message: 'Invalid token' 
      });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        success: false,
        message: 'Token expired' 
      });
    }
    
    res.status(500).json({ 
      success: false,
      message: 'Authentication failed' 
    });
  }
};

module.exports = auth; 
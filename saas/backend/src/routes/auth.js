const express = require('express');
const router = express.Router();
const { User } = require('../models');
const jwt = require('jsonwebtoken');
const auth = require('../middleware/auth');
const bcrypt = require('bcrypt');

// Signup route
router.post('/signup', async (req, res) => {
  try {
    console.log('Signup request body:', req.body);
    const { email, password, confirmPassword, firstName, lastName, companyName } = req.body;

    // Validate password match
    if (password !== confirmPassword) {
      console.log('Password mismatch:', { password, confirmPassword });
      return res.status(400).json({ 
        success: false,
        message: 'Passwords do not match' 
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      console.log('User already exists:', email);
      return res.status(400).json({ 
        success: false,
        message: 'Email already registered' 
      });
    }

    // Create new user
    const user = await User.create({
      email,
      password,
      firstName,
      lastName,
      companyName
    });

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        companyName: user.companyName,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error creating user',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Login route
router.post('/login', async (req, res) => {
  try {
    console.log('Login attempt:', req.body.email);
    
    const { email, password } = req.body;

    // Validate request body
    if (!email || !password) {
      console.log('Missing email or password');
      return res.status(400).json({ 
        success: false,
        message: 'Email and password are required' 
      });
    }

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      console.log('User not found:', email);
      return res.status(401).json({ 
        success: false,
        message: 'Invalid credentials' 
      });
    }

    // Validate password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      console.log('Invalid password for user:', email);
      return res.status(401).json({ 
        success: false,
        message: 'Invalid credentials' 
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET || 'your-secret-key',
      { expiresIn: '24h' }
    );

    console.log('Login successful for user:', email);

    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        companyName: user.companyName,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Login error details:', {
      message: error.message,
      stack: error.stack,
      email: req.body.email
    });
    res.status(500).json({ 
      success: false,
      message: 'Error during login',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Change password route
router.post('/change-password', auth, async (req, res) => {
  try {
    console.log('Change password request received for user:', req.user.id);
    const { currentPassword, newPassword, confirmNewPassword } = req.body;

    // Validate request body
    if (!currentPassword || !newPassword || !confirmNewPassword) {
      console.log('Missing required fields');
      return res.status(400).json({ 
        success: false,
        message: 'All password fields are required' 
      });
    }

    // Validate new password match
    if (newPassword !== confirmNewPassword) {
      console.log('New passwords do not match');
      return res.status(400).json({ 
        success: false,
        message: 'New passwords do not match' 
      });
    }

    // Find user
    const user = await User.findByPk(req.user.id);
    if (!user) {
      console.log('User not found:', req.user.id);
      return res.status(404).json({ 
        success: false,
        message: 'User not found' 
      });
    }

    // Validate current password
    const isValidPassword = await bcrypt.compare(currentPassword, user.password);
    if (!isValidPassword) {
      console.log('Invalid current password for user:', req.user.id);
      return res.status(401).json({ 
        success: false,
        message: 'Current password is incorrect' 
      });
    }

    // Hash new password
    console.log('Hashing new password...');
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    
    // Update password
    console.log('Updating password...');
    await user.update({ password: hashedPassword });
    console.log('Password updated successfully for user:', req.user.id);

    res.json({ 
      success: true,
      message: 'Password updated successfully' 
    });
  } catch (error) {
    console.error('Password change error:', error);
    res.status(500).json({ 
      success: false,
      message: 'Error changing password',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router; 
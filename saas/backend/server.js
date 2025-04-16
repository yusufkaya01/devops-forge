const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const app = express();

// Enable CORS
app.use(cors({
  origin: 'http://localhost:3001',
  credentials: true
}));

// Parse JSON bodies
app.use(bodyParser.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Login endpoint
app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;
  console.log('Login attempt:', { email });
  
  // For testing, accept any email/password
  if (email && password) {
    res.json({
      token: 'test-token-123',
      user: {
        email,
        firstName: 'Test',
        lastName: 'User'
      }
    });
  } else {
    res.status(400).json({ message: 'Email and password are required' });
  }
});

// Signup endpoint
app.post('/auth/signup', (req, res) => {
  const { email, password, firstName, lastName, companyName } = req.body;
  console.log('Signup attempt:', { email, firstName, lastName, companyName });
  
  // For testing, accept any valid data
  if (email && password && firstName && lastName && companyName) {
    res.json({
      token: 'test-token-123',
      user: {
        email,
        firstName,
        lastName,
        companyName
      }
    });
  } else {
    res.status(400).json({ message: 'All fields are required' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}`);
}); 
import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import axios from 'axios';
import Layout from './components/Layout';
import Dashboard from './components/Dashboard';

const API_URL = 'http://localhost:3000';

// Configure axios defaults
axios.defaults.baseURL = API_URL;
axios.defaults.headers.common['Content-Type'] = 'application/json';
axios.defaults.withCredentials = true;

// Add response interceptor for better error handling
axios.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error Details:', {
      message: error.message,
      response: error.response?.data,
      status: error.response?.status,
      headers: error.response?.headers,
      config: error.config
    });
    return Promise.reject(error);
  }
);

// Health check function
const checkServerHealth = async () => {
  try {
    console.log('Attempting to connect to backend server...');
    const response = await axios.get('/');
    console.log('Health check response:', response.data);
    return true;
  } catch (error) {
    console.error('Health check failed:', error.message);
    return false;
  }
};

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

const LoginPage = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    firstName: '',
    lastName: '',
    companyName: ''
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [serverStatus, setServerStatus] = useState('checking');

  useEffect(() => {
    const verifyServer = async () => {
      try {
        console.log('Starting server verification...');
        const isHealthy = await checkServerHealth();
        console.log('Server health check result:', isHealthy);
        
        setServerStatus(isHealthy ? 'healthy' : 'unhealthy');
        if (!isHealthy) {
          setError(
            'Backend server connection failed. Please ensure:\n' +
            '1. The backend server is running (Run: npm start in backend directory)\n' +
            '2. It is running on port 3000\n' +
            '3. Check browser console (F12) for detailed error messages'
          );
        }
      } catch (error) {
        console.error('Server verification failed:', error);
        setServerStatus('unhealthy');
        setError(
          'Server verification failed. Check console (F12) for details.\n' +
          'Common issues:\n' +
          '1. Backend server not running\n' +
          '2. Port conflict\n' +
          '3. CORS configuration'
        );
      }
    };
    verifyServer();
  }, []);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setIsLoading(true);

    try {
      const endpoint = isLogin ? '/auth/login' : '/auth/signup';
      const payload = isLogin 
        ? { email: formData.email, password: formData.password }
        : {
            email: formData.email,
            password: formData.password,
            firstName: formData.firstName,
            lastName: formData.lastName,
            companyName: formData.companyName
          };

      console.log('Sending request to:', `${API_URL}${endpoint}`);
      console.log('Request payload:', payload);

      const response = await axios.post(endpoint, payload);

      console.log('Response received:', response.data);

      if (response.data.token) {
        localStorage.setItem('token', response.data.token);
        setSuccess(isLogin ? 'Login successful!' : 'Account created successfully!');
        setTimeout(() => {
          window.location.href = '/dashboard';
        }, 1000);
      }
    } catch (err) {
      console.error('Full error object:', err);
      if (err.response) {
        const errorMessage = err.response.data?.message || 
                           err.response.data?.error || 
                           'An error occurred during the request';
        setError(`Error (${err.response.status}): ${errorMessage}`);
      } else if (err.request) {
        console.error('No response received:', err.request);
        setError('Unable to connect to the server. Please check if the backend is running on port 3000.');
      } else {
        console.error('Request setup error:', err.message);
        setError(`Request error: ${err.message}`);
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div style={{ 
      display: 'flex', 
      justifyContent: 'center', 
      alignItems: 'center', 
      minHeight: '100vh',
      background: 'linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%)'
    }}>
      <div style={{
        background: 'white',
        padding: '2rem',
        borderRadius: '8px',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        width: '100%',
        maxWidth: '400px'
      }}>
        <h2 style={{ textAlign: 'center', marginBottom: '1.5rem' }}>
          {isLogin ? 'Login' : 'Sign Up'}
        </h2>
        {error && (
          <div style={{ 
            color: 'red', 
            marginBottom: '1rem',
            padding: '0.5rem',
            background: '#ffebee',
            borderRadius: '4px',
            textAlign: 'center'
          }}>
            {error}
          </div>
        )}
        {success && (
          <div style={{ 
            color: 'green', 
            marginBottom: '1rem',
            padding: '0.5rem',
            background: '#e8f5e9',
            borderRadius: '4px',
            textAlign: 'center'
          }}>
            {success}
          </div>
        )}
        <form onSubmit={handleSubmit}>
          {!isLogin && (
            <>
              <div style={{ marginBottom: '1rem' }}>
                <input
                  type="text"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleChange}
                  placeholder="First Name"
                  required
                  style={{
                    width: '100%',
                    padding: '0.5rem',
                    borderRadius: '4px',
                    border: '1px solid #ddd'
                  }}
                />
              </div>
              <div style={{ marginBottom: '1rem' }}>
                <input
                  type="text"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleChange}
                  placeholder="Last Name"
                  required
                  style={{
                    width: '100%',
                    padding: '0.5rem',
                    borderRadius: '4px',
                    border: '1px solid #ddd'
                  }}
                />
              </div>
              <div style={{ marginBottom: '1rem' }}>
                <input
                  type="text"
                  name="companyName"
                  value={formData.companyName}
                  onChange={handleChange}
                  placeholder="Company Name"
                  required
                  style={{
                    width: '100%',
                    padding: '0.5rem',
                    borderRadius: '4px',
                    border: '1px solid #ddd'
                  }}
                />
              </div>
            </>
          )}
          <div style={{ marginBottom: '1rem' }}>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="Email"
              required
              style={{
                width: '100%',
                padding: '0.5rem',
                borderRadius: '4px',
                border: '1px solid #ddd'
              }}
            />
          </div>
          <div style={{ marginBottom: '1rem' }}>
            <input
              type="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="Password"
              required
              style={{
                width: '100%',
                padding: '0.5rem',
                borderRadius: '4px',
                border: '1px solid #ddd'
              }}
            />
          </div>
          {!isLogin && (
            <div style={{ marginBottom: '1rem' }}>
              <input
                type="password"
                name="confirmPassword"
                value={formData.confirmPassword}
                onChange={handleChange}
                placeholder="Confirm Password"
                required
                style={{
                  width: '100%',
                  padding: '0.5rem',
                  borderRadius: '4px',
                  border: '1px solid #ddd'
                }}
              />
            </div>
          )}
          <button
            type="submit"
            disabled={isLoading}
            style={{
              width: '100%',
              padding: '0.75rem',
              background: isLoading ? '#ccc' : '#1976d2',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: isLoading ? 'not-allowed' : 'pointer'
            }}
          >
            {isLoading ? 'Processing...' : (isLogin ? 'Login' : 'Sign Up')}
          </button>
        </form>
        <div style={{ textAlign: 'center', marginTop: '1rem' }}>
          <button
            onClick={() => setIsLogin(!isLogin)}
            disabled={isLoading}
            style={{
              background: 'none',
              border: 'none',
              color: '#1976d2',
              cursor: isLoading ? 'not-allowed' : 'pointer',
              textDecoration: 'underline',
              opacity: isLoading ? 0.5 : 1
            }}
          >
            {isLogin ? 'Need an account? Sign Up' : 'Already have an account? Login'}
          </button>
        </div>
      </div>
    </div>
  );
};

const PrivateRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  return token ? children : <Navigate to="/" />;
};

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Routes>
          <Route path="/" element={<LoginPage />} />
          <Route
            path="/dashboard"
            element={
              <PrivateRoute>
                <Layout>
                  <Dashboard />
                </Layout>
              </PrivateRoute>
            }
          />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App; 
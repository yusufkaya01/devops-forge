import React, { useState } from 'react';
import axios from 'axios';

const API_URL = 'http://localhost:3000/api';

const Settings = () => {
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmNewPassword, setConfirmNewPassword] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleChangePassword = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (newPassword !== confirmNewPassword) {
      setError('New passwords do not match');
      return;
    }

    try {
      const token = localStorage.getItem('token');
      if (!token) {
        setError('You must be logged in to change your password');
        return;
      }

      console.log('Sending password change request...');
      const response = await axios.post(
        `${API_URL}/auth/change-password`,
        {
          currentPassword,
          newPassword,
          confirmNewPassword
        },
        {
          headers: {
            Authorization: `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('Password change response:', response.data);

      if (response.data.success) {
        setSuccess('Password changed successfully');
        setCurrentPassword('');
        setNewPassword('');
        setConfirmNewPassword('');
      } else {
        setError(response.data.message || 'Error changing password');
      }
    } catch (err) {
      console.error('Password change error details:', {
        message: err.message,
        response: err.response?.data,
        status: err.response?.status,
        headers: err.response?.headers
      });

      if (err.response) {
        if (err.response.status === 401) {
          setError('Your session has expired. Please log in again.');
          localStorage.removeItem('token');
        } else {
          setError(err.response.data?.message || 'Error changing password');
        }
      } else if (err.request) {
        setError('Unable to connect to the server. Please try again later.');
      } else {
        setError('An unexpected error occurred. Please try again.');
      }
    }
  };

  return (
    <div style={{ padding: '2rem' }}>
      <h2>Account Settings</h2>
      <div style={{ maxWidth: '400px', marginTop: '2rem' }}>
        <h3>Change Password</h3>
        {error && (
          <div style={{ 
            color: 'red', 
            marginBottom: '1rem',
            padding: '0.5rem',
            background: '#ffebee',
            borderRadius: '4px'
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
            borderRadius: '4px'
          }}>
            {success}
          </div>
        )}
        <form onSubmit={handleChangePassword}>
          <div style={{ marginBottom: '1rem' }}>
            <input
              type="password"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              placeholder="Current Password"
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
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="New Password"
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
              value={confirmNewPassword}
              onChange={(e) => setConfirmNewPassword(e.target.value)}
              placeholder="Confirm New Password"
              required
              style={{
                width: '100%',
                padding: '0.5rem',
                borderRadius: '4px',
                border: '1px solid #ddd'
              }}
            />
          </div>
          <button
            type="submit"
            style={{
              width: '100%',
              padding: '0.75rem',
              background: '#1976d2',
              color: 'white',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer'
            }}
          >
            Change Password
          </button>
        </form>
      </div>
    </div>
  );
};

export default Settings; 
import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  TextField,
  Button,
  Box,
  Avatar,
  Grid,
  Snackbar,
  Alert
} from '@mui/material';
import axios from 'axios';

const Profile = () => {
  const [profile, setProfile] = useState({
    name: '',
    email: '',
    company: '',
    role: ''
  });
  const [isEditing, setIsEditing] = useState(false);
  const [message, setMessage] = useState('');
  const [severity, setSeverity] = useState('success');
  const [openSnackbar, setOpenSnackbar] = useState(false);

  useEffect(() => {
    // Fetch user profile data
    const fetchProfile = async () => {
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get('http://localhost:3001/api/user/profile', {
          headers: { Authorization: `Bearer ${token}` }
        });
        setProfile(response.data);
      } catch (error) {
        console.error('Error fetching profile:', error);
        showMessage('Error fetching profile data', 'error');
      }
    };
    fetchProfile();
  }, []);

  const handleChange = (e) => {
    setProfile({
      ...profile,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      await axios.put('http://localhost:3001/api/user/profile', profile, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setIsEditing(false);
      showMessage('Profile updated successfully', 'success');
    } catch (error) {
      console.error('Error updating profile:', error);
      showMessage('Error updating profile', 'error');
    }
  };

  const showMessage = (msg, sev) => {
    setMessage(msg);
    setSeverity(sev);
    setOpenSnackbar(true);
  };

  return (
    <Container maxWidth="md">
      <Paper elevation={3} sx={{ p: 4, mt: 4 }}>
        <Box display="flex" alignItems="center" mb={4}>
          <Avatar
            sx={{ width: 100, height: 100, mr: 3 }}
            alt={profile.name}
            src="/static/images/avatar/1.jpg"
          />
          <Typography variant="h4" component="h1">
            My Profile
          </Typography>
        </Box>

        <form onSubmit={handleSubmit}>
          <Grid container spacing={3}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Name"
                name="name"
                value={profile.name}
                onChange={handleChange}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Email"
                name="email"
                value={profile.email}
                disabled
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Company"
                name="company"
                value={profile.company}
                onChange={handleChange}
                disabled={!isEditing}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Role"
                name="role"
                value={profile.role}
                onChange={handleChange}
                disabled={!isEditing}
              />
            </Grid>
          </Grid>

          <Box mt={4} display="flex" justifyContent="flex-end">
            {!isEditing ? (
              <Button
                variant="contained"
                color="primary"
                onClick={() => setIsEditing(true)}
              >
                Edit Profile
              </Button>
            ) : (
              <>
                <Button
                  variant="outlined"
                  color="secondary"
                  onClick={() => setIsEditing(false)}
                  sx={{ mr: 2 }}
                >
                  Cancel
                </Button>
                <Button
                  variant="contained"
                  color="primary"
                  type="submit"
                >
                  Save Changes
                </Button>
              </>
            )}
          </Box>
        </form>
      </Paper>

      <Snackbar
        open={openSnackbar}
        autoHideDuration={6000}
        onClose={() => setOpenSnackbar(false)}
      >
        <Alert
          onClose={() => setOpenSnackbar(false)}
          severity={severity}
          sx={{ width: '100%' }}
        >
          {message}
        </Alert>
      </Snackbar>
    </Container>
  );
};

export default Profile; 
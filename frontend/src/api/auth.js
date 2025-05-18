import api from './config'

export const authAPI = {
  // Login
  login(credentials) {
    return api.post('/login', { user: credentials })
  },
  
  // Signup
  signup(userData) {
    return api.post('/signup', { 
      user: {
        first_name: userData.first_name,
        last_name: userData.last_name,
        email: userData.email,
        password: userData.password
      }
    })
  }
} 
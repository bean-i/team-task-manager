import api from './config'

export const authAPI = {
  // 로그인
  login(credentials) {
    return api.post('/login', { user: credentials })
  },
  
  // 회원가입
  signup(userData) {
    return api.post('/signup', { user: userData })
  }
} 
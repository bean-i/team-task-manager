import axios from 'axios'
import { useAuthStore } from '../stores/auth'
import router from '../router'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
})

api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  response => response,
  error => {
    if (!error.response) {
      return Promise.reject({
        response: {
          data: {
            message: 'サーバーに接続できません。ネットワーク接続を確認してください。'
          }
        }
      })
    }
    
    if (error.response?.status === 401) {
      if (router.currentRoute.value.path === '/login') {
        return Promise.reject(error)
      }
      const authStore = useAuthStore()
      authStore.logout()
      router.push('/login')
      return Promise.reject(new Error('認証が切れました。再度ログインしてください。'))
    }
    return Promise.reject(error)
  }
)

export default api 
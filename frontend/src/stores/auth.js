import { defineStore } from 'pinia'
import { authAPI } from '@/api/auth'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: localStorage.getItem('token'),
    loading: false,
    error: null
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    getUser: (state) => state.user
  },

  actions: {
    async login(email, password) {
      this.loading = true
      this.error = null
      
      try {
        const response = await authAPI.login({ email, password })
        const { token, user } = response.data.data
        
        this.token = token
        this.user = user
        localStorage.setItem('token', token)
        
        return true
      } catch (error) {
        this.error = error.response?.data?.message || 'ログインに失敗しました'
        return false
      } finally {
        this.loading = false
      }
    },

    async signup(userData) {
      this.loading = true
      this.error = null
      
      try {
        const response = await authAPI.signup(userData)
        if (response.data.status === 'success') {
          const { user, token } = response.data.data
          this.token = token
          this.user = user
          localStorage.setItem('token', token)
          return true
        } else {
          throw new Error('Invalid response format')
        }
      } catch (error) {
        this.error = error.response?.data?.message || 'ユーザー登録に失敗しました'
        return false
      } finally {
        this.loading = false
      }
    },

    logout() {
      this.user = null
      this.token = null
      localStorage.removeItem('token')
    }
  }
}) 
import { defineStore } from 'pinia'
import { authAPI } from '@/api/auth'
import { useErrorBanner } from '@/composables/useErrorBanner'
import router from '@/router'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user') || 'null'),
    token: localStorage.getItem('token'),
    loading: false,
    error: null,
    ...useErrorBanner()
  }),

  getters: {
    isAuthenticated: (state) => !!state.token,
    getUser: (state) => state.user
  },

  actions: {
    async login(email, password) {
      this.loading = true
      this.error = null
      this.clearErrorBanner()
      try {
        const response = await authAPI.login({ email, password })
        const { token, user } = response.data.data
        this.token = token
        this.user = user
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
        return true
      } catch (error) {
        this.handleApiError(error)
        return false
      } finally {
        this.loading = false
      }
    },

    async signup(userData) {
      this.loading = true
      this.error = null
      this.clearErrorBanner()
      
      try {
        const response = await authAPI.signup(userData)
        if (response.data.status === 'success') {
          router.push('/login')
          return true
        } else {
          throw new Error('Invalid response format')
        }
      } catch (error) {
        this.handleApiError(error)
        return false
      } finally {
        this.loading = false
      }
    },

    logout() {
      this.user = null
      this.token = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
}) 
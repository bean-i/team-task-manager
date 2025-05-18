<template lang="pug">
.dashboard-container
  .dashboard-header
    h1.dashboard-title ダッシュボード
    button.logout-button(@click="handleLogout") ログアウト
  
  .dashboard-content
    .welcome-message
      | ようこそ、{{ authStore.user?.email }}さん
</template>

<script>
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'

export default {
  name: 'DashboardView',
  setup() {
    const authStore = useAuthStore()
    const router = useRouter()

    const handleLogout = () => {
      authStore.logout()
      router.push('/login')
    }

    return {
      authStore,
      handleLogout
    }
  }
}
</script>

<style scoped>
.dashboard-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.dashboard-title {
  font-size: 24px;
  font-weight: 700;
  color: #333;
}

.logout-button {
  padding: 8px 16px;
  background-color: #ef4444;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.logout-button:hover {
  background-color: #dc2626;
}

.dashboard-content {
  background-color: white;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.welcome-message {
  font-size: 16px;
  color: #333;
}
</style> 
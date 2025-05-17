import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '@/pages/LoginView.vue'

const routes = [
  { path: '/', name: 'login', component: LoginView }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router

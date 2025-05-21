import { defineStore } from 'pinia'
import api from '@/api/config'
import { taskAPI } from '@/api/task'

export const useTaskStore = defineStore('task', {
  state: () => ({
    tasks: [],
    members: [],
    loading: false,
    error: null,
    nextCursor: null,
    filters: {
      category: null,
      status: null,
      user_id: null,
      search: ''
    }
  }),

  getters: {
    filteredTasks: (state) => {
      return Array.isArray(state.tasks)
        ? state.tasks.filter(task => {
            if (state.filters.search && !task.title.includes(state.filters.search)) return false
            return true
          })
        : []
    }
  },

  actions: {
    async fetchTasks(workspaceId, cursor = null, append = false) {
      if (this.loading) return
      this.loading = true
      try {
        let params = {}
        if (cursor) params.cursor = cursor
        if (this.filters.status) params['filters[status]'] = this.filters.status
        if (this.filters.category) params['filters[category]'] = this.filters.category
        if (this.filters.user_id) params['filters[user_id]'] = this.filters.user_id

        const response = await api.get(`/workspaces/${workspaceId}`, { params })
        const data = response.data.data || {}
        const newTasks = Array.isArray(data.tasks) ? data.tasks : []
        if (append) {
          const existingIds = new Set(this.tasks.map(t => t.id))
          const filtered = newTasks.filter(t => !existingIds.has(t.id))
          this.tasks = this.tasks.concat(filtered)
        } else {
          this.tasks = newTasks
        }
        this.nextCursor = data.pagination?.next_cursor
        this.members = Array.isArray(data.workspace?.users) ? data.workspace.users : []
        this.error = null
      } catch (err) {
        this.error = err.message
        this.tasks = []
        this.members = []
      } finally {
        this.loading = false
      }
    },

    async createTask(workspaceId, taskData) {
      try {
        const response = await taskAPI.createTask(workspaceId, taskData)
        this.tasks.push(response.data.task || response.data)
        return response.data.task || response.data
      } catch (err) {
        this.error = err.message
        throw err
      }
    },

    async updateTask(workspaceId, taskId, taskData) {
      try {
        const response = await taskAPI.updateTask(workspaceId, taskId, taskData)
        const updated = response.data.task || response.data
        const index = this.tasks.findIndex(task => task.id === taskId)
        if (index !== -1) {
          this.tasks[index] = updated
        }
        return updated
      } catch (err) {
        this.error = err.message
        throw err
      }
    },

    async deleteTask(workspaceId, taskId) {
      try {
        await taskAPI.deleteTask(workspaceId, taskId)
        this.tasks = this.tasks.filter(task => task.id !== taskId)
      } catch (err) {
        this.error = err.message
        throw err
      }
    },

    setFilters(filters) {
      this.filters = { ...filters }
    },

    async loadMore(workspaceId) {
      if (!workspaceId) return
      if (this.nextCursor && !this.loading) {
        await this.fetchTasks(workspaceId, this.nextCursor, true)
      }
    }
  }
}) 
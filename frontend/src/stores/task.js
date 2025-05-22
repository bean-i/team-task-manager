import { defineStore } from 'pinia'
import api from '@/api/config'
import { taskAPI } from '@/api/task'
import { useErrorBanner } from '@/composables/useErrorBanner'

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
    },
    ...useErrorBanner()
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
        this.handleApiError(err)
      } finally {
        this.loading = false
      }
    },

    async createTask(workspaceId, taskData) {
      this.loading = true
      try {
        const response = await taskAPI.createTask(workspaceId, taskData)
        this.tasks.push(response.data.data.task)
        this.error = null
        return response.data.data.task
      } catch (err) {
        this.error = err.message
        this.handleApiError(err)
        return null
      } finally {
        this.loading = false
      }
    },

    async updateTask(workspaceId, taskId, taskData) {
      this.loading = true
      try {
        const response = await taskAPI.updateTask(workspaceId, taskId, taskData)
        const updatedTask = response.data.data.task
        const idx = this.tasks.findIndex(t => t.id === updatedTask.id)
        if (idx !== -1) this.tasks[idx] = updatedTask
        this.error = null
        return updatedTask
      } catch (err) {
        this.error = err.message
        this.handleApiError(err)
        return null
      } finally {
        this.loading = false
      }
    },

    async deleteTask(workspaceId, taskId) {
      this.loading = true
      try {
        await taskAPI.deleteTask(workspaceId, taskId)
        this.tasks = this.tasks.filter(t => t.id !== taskId)
        this.error = null
        return true
      } catch (err) {
        this.error = err.message
        this.handleApiError(err)
        return false
      } finally {
        this.loading = false
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
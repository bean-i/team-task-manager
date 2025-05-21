import { defineStore } from 'pinia'
import api from '@/api/config'

export const useProgressStore = defineStore('progress', {
  state: () => ({
    myProgress: null,
    workspaceProgress: null,
    memberProgress: [],
    loading: false,
    error: null
  }),
  getters: {
    myProgressPercentage: (state) => {
      return state.myProgress ? Math.round(state.myProgress.percent) : 0
    },
    workspaceProgressPercentage: (state) => {
      return state.workspaceProgress ? Math.round(state.workspaceProgress.percent) : 0
    }
  },
  actions: {
    async fetchProgress(workspaceId) {
      if (!workspaceId) return
      this.loading = true
      try {
        const response = await api.get(`/workspaces/${workspaceId}/progress`)
        const data = response.data.data
        this.myProgress = data.my_progress
        this.workspaceProgress = data.workspace_progress
        this.error = null
      } catch (err) {
        this.error = err.message
        this.myProgress = null
        this.workspaceProgress = null
      } finally {
        this.loading = false
      }
    },
    async fetchMemberProgress(workspaceId) {
      if (!workspaceId) return
      this.loading = true
      try {
        const response = await api.get(`/workspaces/${workspaceId}/member_progress`)
        this.memberProgress = response.data.data.members
        this.error = null
      } catch (err) {
        this.error = err.message
        this.memberProgress = []
      } finally {
        this.loading = false
      }
    },
    async refreshAllProgress(workspaceId) {
      if (!workspaceId) return
      await Promise.all([
        this.fetchProgress(workspaceId),
        this.fetchMemberProgress(workspaceId)
      ])
    },
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
    }
  }
})
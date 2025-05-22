import { defineStore } from 'pinia'
import api from '@/api/config'

export const useProgressStore = defineStore('progress', {
  state: () => ({
    summaryList: [],
    loading: false,
    error: null
  }),
  actions: {
    async fetchProgressSummary(workspaceId) {
      if (!workspaceId) return
      this.loading = true
      try {
        const response = await api.get(`/workspaces/${workspaceId}/progress_summary`)
        this.summaryList = response.data.data.summaries
        this.error = null
      } catch (err) {
        this.error = err.message
        this.summaryList = []
      } finally {
        this.loading = false
      }
    }
  }
})
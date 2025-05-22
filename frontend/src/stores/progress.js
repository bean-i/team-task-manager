import { defineStore } from 'pinia'
import { progressAPI } from '@/api/progress'
import { useErrorBanner } from '@/composables/useErrorBanner'

export const useProgressStore = defineStore('progress', {
  state: () => ({
    summaryList: [],
    loading: false,
    error: null,
    ...useErrorBanner()
  }),
  actions: {
    async fetchProgressSummary(workspaceId) {
      if (!workspaceId) return
      this.loading = true
      try {
        const response = await progressAPI.fetchProgressSummary(workspaceId)
        this.summaryList = response.data.data.summaryList || []
        this.error = null
      } catch (err) {
        this.error = err.message
        this.summaryList = []
        this.handleApiError(err)
      } finally {
        this.loading = false
      }
    }
  }
})
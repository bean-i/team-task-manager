import { defineStore } from 'pinia'
import api from '@/api/config'
import { workspaceAPI } from '@/api/workspace'
import { useErrorBanner } from '@/composables/useErrorBanner'

export const useWorkspaceStore = defineStore('workspace', {
  state: () => ({
    workspaces: [],
    currentWorkspace: null,
    loading: false,
    error: null,
    ...useErrorBanner()
  }),
  getters: {
    currentWorkspaceId: (state) => state.currentWorkspace?.id,
    currentWorkspaceName: (state) => state.currentWorkspace?.name
  },
  actions: {
    async fetchWorkspaces() {
      this.loading = true
      try {
        const response = await workspaceAPI.fetchWorkspaces()
        this.workspaces = response.data.data.workspaces || []
        this.error = null
      } catch (err) {
        this.error = err.message
        this.workspaces = []
        this.handleApiError(err)
      } finally {
        this.loading = false
      }
    },
    async fetchWorkspace(id) {
      this.loading = true
      try {
        const response = await workspaceAPI.fetchWorkspace(id)
        this.currentWorkspace = response.data.data?.workspace || response.data.data || null
        this.error = null
      } catch (err) {
        this.error = err.message
        this.currentWorkspace = null
      } finally {
        this.loading = false
      }
    },
    async setCurrentWorkspace(ws) {
      this.currentWorkspace = ws
    }
  }
})
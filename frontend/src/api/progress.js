import api from './config'

export const progressAPI = {
  fetchProgressSummary(workspaceId) {
    return api.get(`/workspaces/${workspaceId}/progress_summary`)
  }
}
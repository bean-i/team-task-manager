import api from './config'

export const progressAPI = {
  fetchMyProgress(workspaceId) {
    return api.get(`/workspaces/${workspaceId}/progress/my`)
  },
  fetchWorkspaceProgress(workspaceId) {
    return api.get(`/workspaces/${workspaceId}/progress/all`)
  },
  fetchMemberProgress(workspaceId) {
    return api.get(`/workspaces/${workspaceId}/progress/members`)
  }
}
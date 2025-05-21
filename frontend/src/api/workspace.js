import api from './config'

export const workspaceAPI = {
  fetchWorkspaces() {
    return api.get('/workspaces')
  },
  fetchWorkspace(id) {
    return api.get(`/workspaces/${id}`)
  },
  createWorkspace(data) {
    return api.post('/workspaces', data)
  },
  joinWorkspace(id) {
    return api.post(`/workspaces/${id}/join`)
  }
}
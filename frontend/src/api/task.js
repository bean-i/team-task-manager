import api from './config'

export const taskAPI = {
  createTask(workspaceId, data) {
    return api.post(`/workspaces/${workspaceId}/tasks`, data)
  },
  updateTask(workspaceId, taskId, data) {
    return api.patch(`/workspaces/${workspaceId}/tasks/${taskId}`, data)
  },
  deleteTask(workspaceId, taskId) {
    return api.delete(`/workspaces/${workspaceId}/tasks/${taskId}`)
  }
}
<template lang="pug">
.dashboard-layout
  .sidebar
    .logo Team Task Manager
    .sidebar-header
      span Workspaces
    ul.workspace-list
      li.workspace-item(v-for="ws in workspaces" :key="ws.id" :class="{ active: ws.id === selectedWorkspace?.id }" @click="selectWorkspace(ws)") {{ ws.title }}
  .main-content
    .header-bar
      h2 {{ selectedWorkspace?.title || 'ワークスペースを選択してください' }}
      button.logout-btn(@click="handleLogout") ログアウト
    .task-section(v-if="selectedWorkspace")
      .task-add-bar
        button.add-task-btn(@click="showAddTaskModal = true") タスク追加
      .task-filters
        .filter-group
          span.filter-label カテゴリー
          select(v-model="filters.category")
            option(value="") すべて
            option(v-for="cat in TASK_CATEGORIES" :key="cat" :value="cat") {{ cat }}
        .filter-group
          span.filter-label ステータス
          select(v-model="filters.status")
            option(value="") すべて
            option(v-for="st in TASK_STATUSES" :key="st" :value="st") {{ st }}
        .filter-group
          span.filter-label 担当者
          select(v-model="filters.user_id")
            option(value="") すべて
            option(v-for="user in members" :key="user.id" :value="user.id") {{ user.last_name + ' ' + user.first_name }}
      .task-table
        table
          thead
            tr
              th タスク
              th カテゴリー
              th ステータス
              th 担当者
          transition-group(name="task-fade" tag="tbody")
            tr(v-for="task in tasks" :key="task.id")
              td {{ task.title }}
              td {{ translateCategory(task.category) }}
              td {{ translateStatus(task.status) }}
              td {{ task.user }}
      .infinite-scroll-footer
        div(v-if="isLoading" class="loading-text") ローディング中...
        button.more-btn(v-else-if="nextCursor" @click="loadMore" :disabled="isLoading") もっと見る
        div(v-else-if="tasks.length > 0" class="end-text") これ以上のタスクはありません
        div(v-else class="end-text") タスクがありません
  TaskModal(:show="showAddTaskModal" :workspace-id="selectedWorkspace?.id" :categories="TASK_CATEGORIES" :statuses="TASK_STATUSES" @close="closeAddTaskModal" @success="onTaskAddSuccess")
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import api from '@/lib/axios'
import TaskModal from '@/components/TaskModal.vue'
import { TASK_CATEGORIES, TASK_STATUSES, translateCategory, translateStatus } from '@/models/task'

const workspaces = ref([])
const selectedWorkspace = ref(null)
const tasks = ref([])
const filters = reactive({ category: '', status: '', user_id: '' })
const members = ref([])
const nextCursor = ref(null)
const isLoading = ref(false)
const showAddTaskModal = ref(false)

const fetchWorkspaces = async () => {
  try {
    const res = await api.get('/workspaces')
    const ws = res.data?.data?.workspaces || []
    workspaces.value = ws
    if (!selectedWorkspace.value && workspaces.value.length > 0) {
      selectWorkspace(workspaces.value[0])
    }
  } catch (e) {
    console.error('Failed to fetch workspaces', e)
  }
}

const selectWorkspace = async (ws) => {
  selectedWorkspace.value = ws
  filters.category = ''
  filters.status = ''
  filters.user_id = ''
  tasks.value = []
  nextCursor.value = null
  await fetchTasks()
}

const fetchTasks = async (cursor = null, append = false) => {
  if (!selectedWorkspace.value) return
  if (isLoading.value) return
  isLoading.value = true
  try {
    let params = { ...filters }
    if (cursor) params.cursor = cursor
    const res = await api.get(`/workspaces/${selectedWorkspace.value.id}`, { params })
    const newTasks = res.data.data.tasks
    console.log('newTasks:', newTasks)
    if (append) {
      const existingIds = new Set(tasks.value.map(t => t.id))
      const filtered = newTasks.filter(t => !existingIds.has(t.id))
      console.log('filtered:', filtered)
      tasks.value = tasks.value.concat(filtered)
    } else {
      tasks.value = newTasks
    }
    nextCursor.value = res.data.data.pagination?.next_cursor
    console.log('Next Cursor:', nextCursor.value)
    if (res.data.data.workspace && res.data.data.workspace.users) {
      members.value = res.data.data.workspace.users
    }
  } catch (e) {
    console.error('Failed to fetch tasks', e)
  } finally {
    isLoading.value = false
  }
}

const loadMore = () => {
  if (nextCursor.value && !isLoading.value) {
    fetchTasks(nextCursor.value, true)
  }
}

watch(filters, () => {
  tasks.value = []
  nextCursor.value = null
  fetchTasks()
  window.scrollTo(0, 0)
}, { deep: true })

onMounted(fetchWorkspaces)

const handleLogout = () => {
  localStorage.removeItem('token')
  window.location.href = '/login'
}

const closeAddTaskModal = () => {
  showAddTaskModal.value = false
}

const onTaskAddSuccess = async () => {
  tasks.value = []
  nextCursor.value = null
  window.scrollTo(0, 0)
  await fetchTasks()
}
</script>

<style scoped>
.dashboard-layout {
  display: flex;
  width: 100vw;
  min-height: 100vh;
  background: #f5f6fa;
}

.sidebar {
  width: 260px;
  min-width: 220px;
  background: #fff;
  border-right: 1px solid #e5e7eb;
  padding: 0 0 24px 0;
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.logo {
  font-size: 22px;
  font-weight: bold;
  padding: 28px 24px 8px 24px;
  letter-spacing: 0.5px;
  color: #222;
}

.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px 16px 24px;
  font-weight: bold;
  font-size: 18px;
}

.workspace-list {
  list-style: none;
  padding: 0 24px;
  margin: 0;
}

.workspace-item {
  padding: 10px 0;
  cursor: pointer;
  border-radius: 4px;
  transition: background 0.2s;
}

.workspace-item.active,
.workspace-item:hover {
  background: #e5e7eb;
}

.main-content {
  flex: 1 1 0;
  min-width: 0;
  padding: 32px;
  overflow-y: auto;
  width: 100%;
  box-sizing: border-box;
}

.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.logout-btn {
  background: #ef4444;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 16px;
  cursor: pointer;
}

.task-section {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.06);
}

.task-add-bar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 12px;
}

.add-task-btn {
  background: #2563eb;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 20px;
  font-size: 16px;
  cursor: pointer;
}

.task-filters {
  display: flex;
  gap: 16px;
  margin-bottom: 16px;
  align-items: flex-end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 140px;
}

.filter-label {
  font-size: 14px;
  font-weight: bold;
  color: #4b5563;
  margin-bottom: 2px;
}

.filter-group select {
  width: 100%;
  padding: 6px 8px;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  font-size: 14px;
  height: 32px;
}

.task-table {
  margin-bottom: 16px;
}

.task-table table {
  width: 100%;
  border-collapse: collapse;
}

.task-table th,
.task-table td {
  border: 1px solid #e5e7eb;
  padding: 8px 12px;
  text-align: left;
}

.infinite-scroll-footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 16px 0 0 0;
  gap: 8px;
}

.loading-text {
  color: #888;
  font-size: 15px;
  margin: 8px 0;
}

.end-text {
  color: #888;
  font-size: 15px;
  margin: 8px 0;
}

.more-btn {
  background: #333;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 24px;
  font-size: 16px;
  cursor: pointer;
  margin: 8px 0;
}

.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: #fff;
  padding: 32px;
  border-radius: 8px;
  min-width: 320px;
  min-height: 120px;
  position: relative;
}

.modal-close {
  position: absolute;
  top: 8px;
  right: 8px;
}

.form-group {
  margin-bottom: 16px;
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-weight: bold;
  margin-bottom: 4px;
}

.form-group input,
.form-group select {
  padding: 8px;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  font-size: 15px;
}

.form-error {
  color: #ef4444;
  margin-bottom: 8px;
}

.form-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.task-fade-enter-active, .task-fade-leave-active {
  transition: all 0.4s cubic-bezier(.55,0,.1,1);
}
.task-fade-enter-from, .task-fade-leave-to {
  opacity: 0;
  transform: translateY(20px);
}
.task-fade-enter-to, .task-fade-leave-from {
  opacity: 1;
  transform: translateY(0);
}
</style>
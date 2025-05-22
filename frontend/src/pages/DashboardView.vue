<template lang="pug">
.dashboard-layout
  ErrorBanner(:message="authStore.errorBanner")
  .sidebar
    .logo Team Task Manager
    .sidebar-header
      span Workspaces
      button.add-ws-btn(@click="openJoinModal") ＋
    ul.workspace-list
      li.workspace-item(v-for="ws in workspaceStore.workspaces" :key="ws.id" :class="{ active: ws.id === workspaceStore.currentWorkspace?.id }" @click="selectWorkspace(ws)") {{ ws.title }}
  .main-content
    .header-bar
      h2 {{ workspaceStore.currentWorkspace?.title || 'ワークスペースを選択してください' }}
      button.logout-btn(@click="handleLogout") ログアウト
    .progress-section(v-if="workspaceStore.currentWorkspace")
      .section-header
        h3.section-title 進捗率
        button.member-progress-btn(@click="openMemberProgressModal") 全体の進捗
      .progress-bars
        .progress-bar-block
          span.label 自分の進捗率
          span.percent {{ mySummary.percent || 0 }}%
          span.ratio {{ mySummary.done || 0 }}/{{ mySummary.total || 0 }}
          .progress-bar-bg
            .progress-bar-fill(:style="{ width: (mySummary.percent || 0) + '%' }")
        .progress-bar-block
          span.label ワークスペース全体の進捗率
          span.percent {{ workspaceSummary.percent || 0 }}%
          span.ratio {{ workspaceSummary.done || 0 }}/{{ workspaceSummary.total || 0 }}
          .progress-bar-bg
            .progress-bar-fill(:style="{ width: (workspaceSummary.percent || 0) + '%' }")
    .section-header(v-if="workspaceStore.currentWorkspace")
      h3.section-title タスク
      button.add-task-btn(@click="showAddTaskModal = true") タスク追加
    .task-section(v-if="workspaceStore.currentWorkspace")
      .task-filters
        .filter-group
          span.filter-label カテゴリー
          select(v-model="filters.category")
            option(value="") すべて
            option(v-for="cat in TASK_CATEGORIES" :key="cat.value" :value="cat.value") {{ cat.label }}
        .filter-group
          span.filter-label ステータス
          select(v-model="filters.status")
            option(value="") すべて
            option(v-for="st in TASK_STATUSES" :key="st.value" :value="st.value") {{ st.label }}
        .filter-group
          span.filter-label 担当者
          select(v-model="filters.user_id")
            option(value="") すべて
            option(v-for="user in taskStore.members" :key="user.id" :value="user.id") {{ user.last_name + ' ' + user.first_name }}
      .task-table
        table
          thead
            tr
              th No
              th タスク
              th カテゴリー
              th ステータス
              th 担当者
              th 操作
          transition-group(name="task-fade" tag="tbody")
            tr(v-for="(task, idx) in taskStore.filteredTasks" :key="task.id")
              td.center {{ idx + 1 }}
              td {{ task.title }}
              td
                span(:class="['badge', 'cat-' + translateCategory(task.category)]") {{ translateCategory(task.category) }}
              td
                span(:class="['badge', 'status-' + translateStatus(task.status)]") {{ translateStatus(task.status) }}
              td {{ task.user }}
              td
                button.edit-btn(@click="openEditModal(task)") 編集
                button.delete-btn(@click="deleteTask(task)") 削除
      .infinite-scroll-footer
        div(v-if="taskStore.loading" class="loading-text") ローディング中...
        button.more-btn(
          v-else-if="taskStore.nextCursor"
          @click="taskStore.loadMore(workspaceStore.currentWorkspace.id)"
          :disabled="taskStore.loading"
        ) もっと見る
        div(v-else-if="taskStore.tasks.length > 0" class="end-text") これ以上のタスクはありません
        div(v-else class="end-text") タスクがありません
  TaskModal(:show="showAddTaskModal" :workspace-id="workspaceStore.currentWorkspace?.id" :categories="TASK_CATEGORIES" :statuses="TASK_STATUSES" @close="closeAddTaskModal" @success="onTaskAddSuccess")
  TaskModal(:show="showEditTaskModal" :workspace-id="workspaceStore.currentWorkspace?.id" :categories="TASK_CATEGORIES" :statuses="TASK_STATUSES" :edit-task="editingTask" :is-edit="true" @close="closeEditTaskModal" @success="onTaskEditSuccess")
  MemberProgressModal(:show="showMemberProgress" :summary-list="progressStore.summaryList" @close="showMemberProgress = false")
  JoinWorkspaceModal(
    :show="showJoinModal"
    :workspaces="availableWorkspaces"
    :tab="tab"
    @update:tab="tab = $event"
    @close="showJoinModal = false"
    @join="handleJoinWorkspace"
    @create="handleCreateWorkspace"
  )
</template>

<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import TaskModal from '@/components/TaskModal.vue'
import MemberProgressModal from '@/components/MemberProgressModal.vue'
import JoinWorkspaceModal from '@/components/JoinWorkspaceModal.vue'
import ErrorBanner from '@/components/ErrorBanner.vue'
import { TASK_CATEGORIES, TASK_STATUSES, translateCategory, translateStatus } from '@/models/task'
import { useTaskStore } from '@/stores/task'
import { useProgressStore } from '@/stores/progress'
import { useWorkspaceStore } from '@/stores/workspace'
import { taskAPI } from '@/api/task'
import { workspaceAPI } from '@/api/workspace'
import { useAuthStore } from '@/stores/auth'

const taskStore = useTaskStore()
const progressStore = useProgressStore()
const workspaceStore = useWorkspaceStore()
const authStore = useAuthStore()

const filters = reactive({ category: '', status: '', user_id: '' })
const showAddTaskModal = ref(false)
const showMemberProgress = ref(false)
const editingTask = ref(null)
const showEditTaskModal = ref(false)
const showJoinModal = ref(false)
const availableWorkspaces = ref([])
const tab = ref('join')

const selectWorkspace = async (ws) => {
  await workspaceStore.setCurrentWorkspace(ws)
  taskStore.setFilters({ category: '', status: '', user_id: '' })
  filters.category = ''
  filters.status = ''
  filters.user_id = ''
  if (workspaceStore.currentWorkspace) {
    await Promise.all([
      taskStore.fetchTasks(workspaceStore.currentWorkspace.id),
      progressStore.fetchProgressSummary(workspaceStore.currentWorkspace.id)
    ])
  }
}

watch(filters, () => {
  if (workspaceStore.currentWorkspace) {
    taskStore.setFilters(filters)
    taskStore.fetchTasks(workspaceStore.currentWorkspace.id)
  }
  window.scrollTo(0, 0)
}, { deep: true })

onMounted(async () => {
  await workspaceStore.fetchWorkspaces()
  if (workspaceStore.workspaces.length > 0) {
    selectWorkspace(workspaceStore.workspaces[0])
  }
})

const handleLogout = () => {
  localStorage.removeItem('token')
  window.location.href = '/login'
}

const closeAddTaskModal = () => {
  showAddTaskModal.value = false
}

const onTaskAddSuccess = async () => {
  if (workspaceStore.currentWorkspace) {
    await Promise.all([
      taskStore.fetchTasks(workspaceStore.currentWorkspace.id),
      progressStore.fetchProgressSummary(workspaceStore.currentWorkspace.id)
    ])
  }
  window.scrollTo(0, 0)
}

const openEditModal = (task) => {
  editingTask.value = { ...task }
  showEditTaskModal.value = true
}

const closeEditTaskModal = () => {
  showEditTaskModal.value = false
  editingTask.value = null
}

const onTaskEditSuccess = async () => {
  if (workspaceStore.currentWorkspace) {
    await Promise.all([
      taskStore.fetchTasks(workspaceStore.currentWorkspace.id),
      progressStore.fetchProgressSummary(workspaceStore.currentWorkspace.id)
    ])
  }
  window.scrollTo(0, 0)
}

const deleteTask = async (task) => {
  if (confirm('本当に削除しますか？')) {
    try {
      await taskAPI.deleteTask(workspaceStore.currentWorkspace.id, task.id)
      await taskStore.fetchTasks(workspaceStore.currentWorkspace.id)
      await progressStore.fetchProgressSummary(workspaceStore.currentWorkspace.id)
    } catch (e) {
      alert('削除に失敗しました')
    }
  }
}

const openMemberProgressModal = async () => {
  if (workspaceStore.currentWorkspace) {
    await progressStore.fetchProgressSummary(workspaceStore.currentWorkspace.id)
    showMemberProgress.value = true
  }
}

const openJoinModal = async () => {
  const res = await workspaceAPI.fetchAvailableWorkspaces()
  availableWorkspaces.value = res.data.data.workspaces || []
  showJoinModal.value = true
}

const handleJoinWorkspace = async (id) => {
  await workspaceAPI.joinWorkspace(id)
  await workspaceStore.fetchWorkspaces()
  showJoinModal.value = false
}

const handleCreateWorkspace = async (title) => {
  try {
    await workspaceAPI.createWorkspace({ title })
    alert('ワークスペースが作成されました')
    await workspaceStore.fetchWorkspaces()
    const res = await workspaceAPI.fetchAvailableWorkspaces()
    availableWorkspaces.value = res.data.data.workspaces || []
    showJoinModal.value = false
    tab.value = 'join'
  } catch (e) {
    alert('作成に失敗しました')
  }
}

const mySummary = computed(() => {
  return progressStore.summaryList.find(s => String(s.user_id) === String(authStore.user?.id)) || {}
})
const workspaceSummary = computed(() => {
  const totalSummary = progressStore.summaryList.find(s => s.user_id === null)
  if (!totalSummary) return {}
  return {
    done: totalSummary.done,
    total: totalSummary.total,
    percent: totalSummary.percent
  }
})
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
  height: 100vh;
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
  margin-top: 0;
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

.task-table tbody tr:hover {
  background: #f1f5f9;
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

.progress-section {
  margin-bottom: 32px;
}
.progress-bars {
  display: flex;
  gap: 48px;
}
.progress-bar-block {
  min-width: 320px;
  margin-bottom: 12px;
}
.progress-bar-block .label {
  font-size: 18px;
  font-weight: bold;
  margin-right: 16px;
}
.progress-bar-block .percent {
  font-size: 20px;
  font-weight: bold;
  margin-left: 12px;
}
.progress-bar-block .ratio {
  font-size: 18px;
  margin-left: 18px;
}
.progress-bar-bg {
  width: 100%;
  height: 36px;
  background: #e5e7eb;
  border-radius: 18px;
  margin-top: 8px;
  overflow: hidden;
}
.progress-bar-fill {
  height: 100%;
  background: #666;
  border-radius: 18px 0 0 18px;
  transition: width 0.5s cubic-bezier(.55,0,.1,1);
}

.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 18px;
  justify-content: flex-start;
}
.section-title {
  font-size: 24px;
  font-weight: bold;
  letter-spacing: 1px;
  color: #222;
  margin: 0;
}
.member-progress-btn,
.add-task-btn {
  margin-left: 16px;
}
.member-progress-btn {
  background: #444;
  color: #fff;
  border: none;
  border-radius: 14px;
  padding: 6px 24px;
  font-size: 18px;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
}
.member-progress-btn:hover {
  background: #222;
}

.section-title + .task-section {
  margin-top: 0;
}

.edit-btn {
  background: #fff;
  color: #2563eb;
  border: 1px solid #2563eb;
  border-radius: 6px;
  padding: 4px 12px;
  font-size: 15px;
  margin-right: 8px;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.edit-btn:hover {
  background: #2563eb;
  color: #fff;
}
.delete-btn {
  background: #fff;
  color: #ef4444;
  border: 1px solid #ef4444;
  border-radius: 6px;
  padding: 4px 12px;
  font-size: 15px;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.delete-btn:hover {
  background: #ef4444;
  color: #fff;
}

.badge {
  display: inline-block;
  padding: 2px 12px;
  border-radius: 12px;
  font-size: 14px;
  font-weight: bold;
  color: #fff;
  margin-right: 2px;
}
.cat-企画 { background: #2563eb; }
.cat-デザイン { background: #10b981; }
.cat-フロントエンド { background: #f59e42; }
.cat-バックエンド { background: #a855f7; }
.cat-テスト { background: #f43f5e; }
.status-未着手 { background: #6b7280; }
.status-進行中 { background: #2563eb; }
.status-完了 { background: #10b981; }

.task-table th:first-child,
.task-table td.center {
  text-align: center;
  width: 48px;
}

.add-ws-btn {
  background: #2563eb;
  color: #fff;
  border: none;
  border-radius: 50%;
  width: 28px;
  height: 28px;
  font-size: 20px;
  font-weight: bold;
  margin-left: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s;
}
.add-ws-btn:hover {
  background: #1741a6;
}
</style>
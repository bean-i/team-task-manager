<template lang="pug">
Modal(v-if="show" @close="emitClose")
  h3 {{ isEdit ? 'タスク編集' : 'タスク追加' }}
  form(@submit.prevent="submitTask")
    .form-group
      label タイトル
      input(type="text" v-model="newTask.title" required)
    .form-group
      label カテゴリー
      select(v-model="newTask.category" required)
        option(value="") 選択してください
        option(v-for="cat in categories" :key="cat.value" :value="cat.value") {{ cat.label }}
    .form-group
      label ステータス
      select(v-model="newTask.status" required)
        option(value="") 選択してください
        option(v-for="st in statuses" :key="st.value" :value="st.value") {{ st.label }}
    .form-error(v-if="addTaskError") {{ addTaskError }}
    .form-actions
      button(type="submit" :disabled="addTaskLoading") {{ isEdit ? '更新' : '追加' }}
      span(v-if="addTaskLoading" class="loading-text") ローディング中...
</template>

<script setup>
import { reactive, ref, watch } from 'vue'
import Modal from './Modal.vue'
import { TASK_CATEGORIES, TASK_STATUSES, CATEGORY_MAP, STATUS_MAP } from '@/models/task'
import { useTaskStore } from '@/stores/task'
import { taskAPI } from '@/api/task'

const taskStore = useTaskStore()

const props = defineProps({
  show: Boolean,
  workspaceId: Number,
  categories: Array,
  statuses: Array,
  isEdit: Boolean,
  editTask: Object
})

const emit = defineEmits(['close', 'success'])
const addTaskLoading = ref(false)
const addTaskError = ref('')
const newTask = reactive({ title: '', category: '', status: '' })

const emitClose = () => {
  emit('close')
  addTaskLoading.value = false
  addTaskError.value = ''
  newTask.title = ''
  newTask.category = ''
  newTask.status = ''
}

watch(() => props.show, (val) => {
  if (val && props.isEdit && props.editTask) {
    newTask.title = props.editTask.title
    newTask.category = props.editTask.category || ''
    newTask.status = props.editTask.status || ''
  } else if (!val) {
    newTask.title = ''
    newTask.category = ''
    newTask.status = ''
  }
})

const submitTask = async () => {
  if (!newTask.title || !newTask.category || !newTask.status) {
    addTaskError.value = '全ての項目を入力してください'
    return
  }
  addTaskLoading.value = true
  addTaskError.value = ''
  try {
    if (props.isEdit && props.editTask) {
      await taskAPI.updateTask(props.workspaceId, props.editTask.id, {
        title: newTask.title,
        category: newTask.category,
        status: newTask.status
      })
    } else {
      await taskAPI.createTask(props.workspaceId, {
        title: newTask.title,
        category: newTask.category,
        status: newTask.status
      })
    }
    emitClose()
    emit('success')
  } catch (e) {
    addTaskError.value = '登録に失敗しました'
  } finally {
    addTaskLoading.value = false
  }
}
</script>

<style scoped>
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

.loading-text {
  color: #888;
  font-size: 15px;
  margin: 8px 0;
}
</style>
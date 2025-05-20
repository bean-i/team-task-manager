<template lang="pug">
Modal(v-if="show" @close="emitClose")
  h3 タスク追加
  form(@submit.prevent="submitTask")
    .form-group
      label タイトル
      input(type="text" v-model="newTask.title" required)
    .form-group
      label カテゴリー
      select(v-model="newTask.category" required)
        option(value="") 選択してください
        option(v-for="cat in TASK_CATEGORIES" :key="cat" :value="cat") {{ cat }}
    .form-group
      label ステータス
      select(v-model="newTask.status" required)
        option(value="") 選択してください
        option(v-for="st in TASK_STATUSES" :key="st" :value="st") {{ st }}
    .form-error(v-if="addTaskError") {{ addTaskError }}
    .form-actions
      button(type="submit" :disabled="addTaskLoading") 追加
      span(v-if="addTaskLoading" class="loading-text") ローディング中...
</template>

<script setup>
import { reactive, ref, watch } from 'vue'
import api from '@/lib/axios'
import Modal from './Modal.vue'
import { TASK_CATEGORIES, TASK_STATUSES } from '@/models/task'
const props = defineProps({
  show: Boolean,
  workspaceId: Number
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

const submitTask = async () => {
  if (!newTask.title || !newTask.category || !newTask.status) {
    addTaskError.value = '全ての項目を入力してください'
    return
  }
  addTaskLoading.value = true
  addTaskError.value = ''
  try {
    await api.post(`/workspaces/${props.workspaceId}/tasks`, {
      title: newTask.title,
      category: newTask.category,
      status: newTask.status
    })
    emitClose()
    emit('success')
  } catch (e) {
    addTaskError.value = '登録に失敗しました'
  } finally {
    addTaskLoading.value = false
  }
}

watch(() => props.show, (val) => {
  if (!val) emitClose()
})
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
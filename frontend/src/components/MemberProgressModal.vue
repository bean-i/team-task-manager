<template lang="pug">
.modal-backdrop(v-if="show")
  .modal-content
    h3 メンバー別進捗率
    table.member-progress-table
      thead
        tr
          th 名前
          th 完了数
          th 総タスク数
          th 進捗率
      tbody
        tr(v-for="mp in summaryList.filter(mp => mp.user_id !== null && mp.user_id !== undefined)" :key="mp.user_id")
          td {{ mp.user_name }}
          td.center {{ mp.done }}
          td.center {{ mp.total }}
          td.center {{ mp.percent }}%
    button(@click="$emit('close')") 閉じる
</template>
<script setup>
import { watch } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
const props = defineProps(['show', 'summaryList'])

watch(
  () => props.summaryList,
  (newList) => {
    console.log('summaryList:', newList)
    console.log('내 user:', authStore.user)
  },
  { immediate: true }
)
</script>
<style scoped>
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
  min-width: 400px;
  min-height: 120px;
  position: relative;
}
h3 {
  margin-bottom: 18px;
  font-size: 22px;
  font-weight: bold;
  text-align: center;
}
.member-progress-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 18px;
}
.member-progress-table th, .member-progress-table td {
  border: 1px solid #e5e7eb;
  padding: 10px 14px;
  font-size: 16px;
  min-width: 80px;
}
.member-progress-table th {
  background: #f3f4f6;
  font-weight: bold;
  text-align: center;
}
.member-progress-table td.center {
  text-align: center;
}
.member-progress-table tbody tr:hover {
  background: #f1f5f9;
}
button {
  margin-top: 8px;
  padding: 8px 24px;
  border-radius: 6px;
  background: #2563eb;
  color: #fff;
  border: none;
  font-size: 16px;
  cursor: pointer;
  display: block;
  margin-left: auto;
  margin-right: auto;
}
</style> 
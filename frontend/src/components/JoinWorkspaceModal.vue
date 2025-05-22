<template lang="pug">
.modal-backdrop(v-if="show")
  .modal-content
    .tab-header
      button.tab-btn(:class="{active: tab==='join'}" @click="$emit('update:tab', 'join')") 参加
      button.tab-btn(:class="{active: tab==='create'}" @click="$emit('update:tab', 'create')") 新規作成
    .tab-content
      template(v-if="tab==='join'")
        ul.ws-join-list
          template(v-if="workspaces.length > 0")
            li(v-for="ws in workspaces" :key="ws.id" class="ws-join-item")
              span.ws-title {{ ws.title }}
              button.join-btn(@click="$emit('join', ws.id)") 参加
          template(v-else)
            li.ws-empty 参加できるワークスペースはありません
      template(v-else)
        input(type="text" v-model="title" placeholder="新しいワークスペース名を入力" class="ws-input")
        button.create-btn(@click="create") 作成
    button.close-btn(@click="$emit('close')") 閉じる
</template>
<script setup>
import { ref, watch } from 'vue'
const props = defineProps(['show', 'workspaces', 'tab'])
const emit = defineEmits(['close', 'join', 'create', 'update:tab'])
const title = ref('')
const create = () => {
  if (title.value.trim()) {
    emit('create', title.value)
    title.value = ''
    emit('update:tab', 'join')
  }
}
watch(() => props.show, (val) => {
  if (!val) title.value = ''
})
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
  padding: 32px 32px 24px 32px;
  border-radius: 8px;
  min-width: 340px;
  min-height: 120px;
  position: relative;
}
.tab-header {
  display: flex;
  justify-content: center;
  margin-bottom: 18px;
  gap: 8px;
}
.tab-btn {
  background: #f3f4f6;
  color: #222;
  border: none;
  border-radius: 6px 6px 0 0;
  padding: 8px 32px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: background 0.2s;
}
.tab-btn.active {
  background: #2563eb;
  color: #fff;
}
.tab-content {
  min-height: 80px;
  margin-bottom: 18px;
  padding: 0;
}
.ws-join-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.ws-join-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f1f5f9;
}
.ws-title {
  font-size: 16px;
  font-weight: 500;
}
.join-btn {
  background: #2563eb;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 6px 18px;
  font-size: 15px;
  cursor: pointer;
  margin-left: 12px;
  transition: background 0.2s;
}
.join-btn:hover {
  background: #1741a6;
}
.ws-input {
  width: 100%;
  box-sizing: border-box;
  padding: 8px 12px;
  border: 1px solid #e5e7eb;
  border-radius: 4px;
  font-size: 16px;
  margin-bottom: 12px;
  display: block;
}
.create-btn {
  background: #10b981;
  color: #fff;
  border: none;
  border-radius: 6px;
  padding: 8px 20px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.2s;
  display: block;
  margin: 0 auto;
}
.create-btn:hover {
  background: #0e8c6b;
}
.close-btn {
  margin-top: 10px;
  padding: 8px 24px;
  border-radius: 6px;
  background: #888;
  color: #fff;
  border: none;
  font-size: 16px;
  cursor: pointer;
  display: block;
  margin-left: auto;
  margin-right: auto;
}
.ws-empty {
  color: #888;
  text-align: center;
  padding: 16px 0;
  font-size: 15px;
}
</style> 
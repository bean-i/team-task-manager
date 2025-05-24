<template lang="pug">
  .error-modal-backdrop(v-if="show")
    .error-modal
      span.error-icon ⚠️
      span.error-text {{ message }}
      button.close-btn(@click="closeModal") ×
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
const props = defineProps(['message'])
const emit = defineEmits(['close'])

const show = ref(!!props.message)
let timer = null

watch(() => props.message, (val) => {
  show.value = !!val
  if (val) {
    clearTimeout(timer)
    timer = setTimeout(() => {
      closeModal()
    }, 3000)
  }
})

function closeModal() {
  show.value = false
  emit('close')
}

onMounted(() => {
  if (props.message) {
    timer = setTimeout(() => {
      closeModal()
    }, 3000)
  }
})
</script>

<style scoped>
.error-modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0,0,0,0.18);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 3000;
}
.error-modal {
  background: #fff;
  border: 2px solid #ef4444;
  border-radius: 12px;
  padding: 32px 36px 24px 36px;
  min-width: 320px;
  min-height: 80px;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-shadow: 0 4px 24px rgba(239, 68, 68, 0.15);
  position: relative;
}
.error-icon {
  font-size: 32px;
  margin-bottom: 12px;
}
.error-text {
  color: #dc2626;
  font-size: 18px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 12px;
}
.close-btn {
  position: absolute;
  top: 8px;
  right: 12px;
  background: transparent;
  border: none;
  font-size: 22px;
  color: #ef4444;
  cursor: pointer;
}
</style> 
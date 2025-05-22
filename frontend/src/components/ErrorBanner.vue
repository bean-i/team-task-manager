<template lang="pug">
.error-banner(v-if="message")
  span.error-icon ⚠️
  span.error-text {{ message }}
</template>

<script setup>
defineProps(['message'])
</script>

<style scoped>
.error-banner {
  background-color: #fee2e2;
  border: 1px solid #ef4444;
  border-radius: 6px;
  padding: 12px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.error-icon {
  font-size: 16px;
}
.error-text {
  color: #dc2626;
  font-size: 14px;
}
</style> 
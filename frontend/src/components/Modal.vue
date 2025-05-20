<template>
  <div class="modal-backdrop" @click.self="$emit('close')">
    <div class="modal-content">
      <button class="modal-close" @click="$emit('close')">×</button>
      <slot />
    </div>
  </div>
</template>

<script setup>
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
  min-width: 320px;
  min-height: 120px;
  position: relative;
}
.modal-close {
  position: absolute;
  top: 8px;
  right: 8px;
}
</style> 
<template lang="pug">
button.submit-button(
  :class="{ disabled: disabled }"
  :disabled="disabled"
  @click="$emit('click')"
) {{ label }}
</template>

<script>
export default {
  name: 'SubmitButton',
  props: {
    label: {
      type: String,
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    }
  },
  emits: ['click']
}
</script>

<style scoped>
.submit-button {
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.3s, opacity 0.3s;
  color: white;
  background-color: #2563eb;
}

.submit-button:hover:not(.disabled) {
  background-color: #1d4ed8;
}

.submit-button.disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}
</style>
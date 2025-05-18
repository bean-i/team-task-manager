<template lang="pug">
button.submit-button(
  type="submit"
  :disabled="disabled"
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
  }
}
</script>

<style scoped>
.submit-button {
  width: 100%;
  padding: 12px;
  background-color: #2563eb;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-button:hover {
  background-color: #1d4ed8;
}

.submit-button:disabled {
  background-color: #93c5fd;
  cursor: not-allowed;
}
</style>
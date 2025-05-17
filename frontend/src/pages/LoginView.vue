<!-- src/views/LoginView.vue -->
<template lang="pug">
.login-container
  .login-card
    h1.login-title ログイン
    
    form(@submit.prevent="handleLogin")
      .form-group
        label(for="email") メールアドレス
        input(
          type="email"
          id="email"
          v-model="email"
          placeholder="例：sample@example.com"
          required
        )
      
      .form-group
        label(for="password") パスワード
        input(
          type="password"
          id="password"
          v-model="password"
          placeholder="例：8文字以上の英数字・記号"
          required
        )
      
      SubmitButton(
        :label="'ログイン'"
        :disabled="!isFormValid"
        @click="handleLogin"
      )
      
      .signup-link
        p アカウントをお持ちでない方はこちら
        router-link(to="/signup") | サインアップ |
</template>

<script>
import { ref, computed } from 'vue'
import SubmitButton from '../components/SubmitButton.vue'

export default {
  name: 'LoginView',
  components: {
    SubmitButton
  },
  setup() {
    const email = ref('')
    const password = ref('')

    const isFormValid = computed(() => {
      return email.value.trim() !== '' && password.value.trim() !== ''
    })

    const handleLogin = () => {
      console.log('ログイン処理:', email.value, password.value)
    }

    return {
      email,
      password,
      isFormValid,
      handleLogin
    }
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  padding: 20px;
  box-sizing: border-box;
}

.login-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  padding: 40px;
  width: 400px;
  max-width: 100%;
}

.login-title {
  text-align: center;
  font-size: 40px;
  font-weight: 700;
  margin-bottom: 32px;
  color: #333;
}

.form-group {
  margin-bottom: 24px;
}

label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: #333;
  text-align: left;
}

input {
  width: 100%;
  padding: 12px;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  font-size: 14px;
  background-color: #f8fafc;
  box-sizing: border-box;
}

input:focus {
  outline: none;
  border-color: #2563eb;
  background-color: white;
}

input::placeholder {
  color: #94a3b8;
}

.signup-link {
  margin-top: 24px;
  text-align: center;
}

.signup-link p {
  margin-bottom: 8px;
  color: #64748b;
  font-size: 14px;
}

.signup-link a {
  color: #2563eb;
  text-decoration: none;
  font-size: 14px;
}

.signup-link a:hover {
  text-decoration: underline;
}
</style>
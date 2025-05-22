<template lang="pug">
.login-container
  .login-card
    ErrorBanner(:message="authStore.errorBanner")
    h1.login-title ログイン
    
    form(@submit.prevent="handleLogin")
      .error-banner(v-if="authStore.error")
        span.error-icon ⚠️
        span.error-text {{ authStore.error }}
      
      .form-group
        label(for="email") メールアドレス
        input(
          type="email"
          id="email"
          v-model="email"
          :class="{ 'error': emailError }"
          placeholder="例：sample@example.com"
          required
          @input="validateEmail"
        )
        .field-error(v-if="emailError") {{ emailError }}
      
      .form-group
        label(for="password") パスワード
        input(
          type="password"
          id="password"
          v-model="password"
          :class="{ 'error': passwordError }"
          placeholder="例：8文字以上の英数字・記号"
          required
          @input="validatePassword"
        )
        .field-error(v-if="passwordError") {{ passwordError }}
      
      SubmitButton(
        :label="authStore.loading ? 'ログイン中...' : 'ログイン'"
        :disabled="!isFormValid || authStore.loading"
        @click="handleLogin"
      )
      
      .signup-link
        p アカウントをお持ちでない方はこちら
        router-link(to="/signup") | サインアップ |
</template>

<script>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import SubmitButton from '../components/SubmitButton.vue'
import ErrorBanner from '../components/ErrorBanner.vue'

export default {
  name: 'LoginView',
  components: {
    SubmitButton,
    ErrorBanner
  },
  setup() {
    const email = ref('')
    const password = ref('')
    const emailError = ref('')
    const passwordError = ref('')
    const router = useRouter()
    const authStore = useAuthStore()

    const validateEmail = () => {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (!email.value) {
        emailError.value = 'メールアドレスを入力してください'
      } else if (!emailRegex.test(email.value)) {
        emailError.value = '有効なメールアドレスを入力してください'
      } else {
        emailError.value = ''
      }
    }

    const validatePassword = () => {
      if (!password.value) {
        passwordError.value = 'パスワードを入力してください'
      } else if (password.value.length < 8) {
        passwordError.value = 'パスワードは8文字以上で入力してください'
      } else {
        passwordError.value = ''
      }
    }

    const isFormValid = computed(() => {
      return email.value && 
             password.value && 
             !emailError.value && 
             !passwordError.value
    })

    const handleLogin = async () => {
      validateEmail()
      validatePassword()
      
      if (!isFormValid.value) return

      if (await authStore.login(email.value, password.value)) {
        router.push('/dashboard')
      }
    }

    return {
      email,
      password,
      emailError,
      passwordError,
      isFormValid,
      handleLogin,
      validateEmail,
      validatePassword,
      authStore
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

.field-error {
  color: #dc2626;
  font-size: 12px;
  margin-top: 4px;
}

input.error {
  border-color: #dc2626;
  background-color: #fef2f2;
}

input.error:focus {
  border-color: #dc2626;
  box-shadow: 0 0 0 1px #dc2626;
}
</style>
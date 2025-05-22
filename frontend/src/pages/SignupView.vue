<template lang="pug">
.signup-container
  .signup-card
    ErrorBanner(:message="authStore.errorBanner")
    h1.signup-title サインアップ
    
    form(@submit.prevent="handleSignup")
      .error-banner(v-if="authStore.error")
        span.error-icon ⚠️
        span.error-text {{ authStore.error }}
      
      .name-fields
        .name-field
          label(for="last_name") 姓 (名字)
          input(
            type="text"
            id="last_name"
            v-model="lastName"
            placeholder="例：山田"
            required
          )
        
        .name-field
          label(for="first_name") 名 (下の名前)
          input(
            type="text"
            id="first_name"
            v-model="firstName"
            placeholder="例：太郎"
            required
          )
      
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
          @input="validatePassword"
        )
        .password-hint パスワードは8文字以上で、英字・数字・記号（! @ # % * のいずれか）をすべて含めてください。

      SubmitButton(
        :label="authStore.loading ? '登録中...' : '登録する'"
        :disabled="!isFormValid || authStore.loading"
        @click="handleSignup"
      )
      
      .login-link
        p アカウントをお持ちの方はこちら
        router-link(to="/login") | ログイン |
</template>

<script>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import SubmitButton from '../components/SubmitButton.vue'
import ErrorBanner from '../components/ErrorBanner.vue'

export default {
  name: 'SignupView',
  components: {
    SubmitButton,
    ErrorBanner
  },
  setup() {
    const firstName = ref('')
    const lastName = ref('')
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
      const passwordRegex = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#%*]).{8,}$/
      if (!password.value) {
        passwordError.value = 'パスワードを入力してください'
      } else if (!passwordRegex.test(password.value)) {
        passwordError.value = 'パスワードは8文字以上で、英字・数字・記号（! @ # % * のいずれか）をすべて含めてください'
      } else {
        passwordError.value = ''
      }
    }

    const isFormValid = computed(() => {
      return firstName.value &&
        lastName.value &&
        email.value &&
        password.value &&
        !emailError.value &&
        !passwordError.value &&
        /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#%*]).{8,}$/.test(password.value) &&
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)
    })

    const handleSignup = async () => {
      if (await authStore.signup({
        first_name: firstName.value,
        last_name: lastName.value,
        email: email.value,
        password: password.value
      })) {
        alert('会員登録が完了しました。ログインしてください。')
        router.push('/login')
      }
    }

    return {
      firstName,
      lastName,
      email,
      password,
      emailError,
      passwordError,
      isFormValid,
      handleSignup,
      validateEmail,
      validatePassword,
      authStore
    }
  }
}
</script>

<style scoped>
.signup-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f3f4f6;
}

.signup-card {
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 440px;
  margin: 0 auto;
  box-sizing: border-box;
}

.signup-title {
  text-align: center;
  font-size: 40px;
  font-weight: 700;
  margin-bottom: 32px;
  color: #333;
}

.name-fields {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  width: 100%;
}

.name-field {
  flex: 1;
  width: 50%;
}

.name-field label,
.form-group label {
  display: block;
  margin-bottom: 8px;
  color: #111827;
  font-size: 14px;
}

.name-field input,
.form-group input {
  width: 100%;
  padding: 8px 16px;
  border: 1px solid #E5E7EB;
  border-radius: 8px;
  font-size: 14px;
  background-color: #F9FAFB;
  height: 42px;
  box-sizing: border-box;
}

.name-field input::placeholder,
.form-group input::placeholder {
  color: #9CA3AF;
}

.form-group {
  margin-bottom: 24px;
  width: 100%;
}

.password-hint {
  margin-top: 8px;
  font-size: 12px;
  color: #6B7280;
}

.submit-button {
  width: 100%;
  padding: 12px;
  background-color: #60A5FA;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  margin-top: 8px;
  height: 48px;
  box-sizing: border-box;
}

.submit-button:hover {
  background-color: #3B82F6;
}

.submit-button:disabled {
  background-color: #93C5FD;
  cursor: not-allowed;
}

.login-link {
  margin-top: 24px;
  text-align: center;
  font-size: 14px;
}

.login-link p {
  color: #6B7280;
  margin-bottom: 4px;
}

.login-link a {
  color: #2563EB;
  text-decoration: none;
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
</style>
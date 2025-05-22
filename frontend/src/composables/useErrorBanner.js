import { ref } from 'vue'

export function useErrorBanner() {
  const errorBanner = ref(null)

  function handleApiError(error) {
    const status = error.response?.status
    const message = error.response?.data?.message || 'サーバーエラーが発生しました。'
    if (status === 401) {
      errorBanner.value = '認証が必要です。再度ログインしてください。'
      // 필요시 로그아웃 등 추가
    } else if (status === 403) {
      errorBanner.value = '権限がありません。'
    } else if (status === 404) {
      errorBanner.value = 'データが見つかりません。'
    } else if (status === 422) {
      errorBanner.value = message
    } else if (status === 500) {
      errorBanner.value = 'サーバーエラーが発生しました。'
    } else {
      errorBanner.value = message
    }
  }

  function clearErrorBanner() {
    errorBanner.value = null
  }

  return { errorBanner, handleApiError, clearErrorBanner }
} 
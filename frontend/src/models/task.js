export const TASK_CATEGORIES = [
  { value: 'planning', label: '企画' },
  { value: 'design', label: 'デザイン' },
  { value: 'frontend', label: 'フロントエンド' },
  { value: 'backend', label: 'バックエンド' },
  { value: 'test', label: 'テスト' }
]

export const TASK_STATUSES = [
  { value: 'not_started', label: '未着手' },
  { value: 'in_progress', label: '進行中' },
  { value: 'completed', label: '完了' }
]

export const CATEGORY_MAP = {
  'planning': '企画',
  'design': 'デザイン',
  'frontend': 'フロントエンド',
  'backend': 'バックエンド',
  'test': 'テスト'
}

export const STATUS_MAP = {
  'not_started': '未着手',
  'in_progress': '進行中',
  'completed': '完了'
}

export const translateCategory = (category) => CATEGORY_MAP[category] || category
export const translateStatus = (status) => STATUS_MAP[status] || status 
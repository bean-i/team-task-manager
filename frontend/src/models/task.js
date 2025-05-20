export const TASK_CATEGORIES = [
  '企画', 'デザイン', 'フロントエンド', 'バックエンド', 'テスト'
]

export const TASK_STATUSES = [
  '未着手', '進行中', '完了'
]

const CATEGORY_MAP = {
  'planning': '企画',
  'design': 'デザイン',
  'frontend': 'フロントエンド',
  'backend': 'バックエンド',
  'testing': 'テスト'
}

const STATUS_MAP = {
  'not_started': '未着手',
  'in_progress': '進行中',
  'completed': '完了'
}

export const translateCategory = (category) => CATEGORY_MAP[category] || category
export const translateStatus = (status) => STATUS_MAP[status] || status 
class Task < ApplicationRecord
  belongs_to :workspace
  belongs_to :user

  enum :status, {
    not_started: '未着手',
    in_progress: '進行中',
    completed: '完了'
  }

  enum :category, {
    planning: '企画',
    design: 'デザイン',
    frontend: 'フロントエンド',
    backend: 'バックエンド',
    test: 'テスト'
  }

  validates :title, presence: true
  validates :status, presence: true
  validates :category, presence: true
  validates :user_id, presence: true
  validates :workspace_id, presence: true
end 
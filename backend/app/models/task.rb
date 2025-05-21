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

  def self.apply_cursor_pagination(query, cursor)
    return query if cursor.blank?
    last_id = cursor.to_i
    query.where('tasks.id < ?', last_id)
  end

  def self.encode_cursor(task)
    task.id.to_s
  end

  def self.decode_cursor(cursor)
    cursor.to_i
  end

  def self.tasks_query
    order(id: :desc)
  end
end 
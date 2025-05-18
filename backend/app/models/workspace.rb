class Workspace < ApplicationRecord
  has_many :users_workspaces
  has_many :users, through: :users_workspaces
  has_many :tasks
  
  validates :title, presence: true
end 
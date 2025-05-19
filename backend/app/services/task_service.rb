class TaskService
  def self.create_task(workspace_id, user, params)
    workspace = Workspace.find(workspace_id)
    
    unless workspace.users.include?(user)
      raise CustomErrors::AuthorizationError.new('ワークスペースのメンバーではありません')
    end
    
    workspace.tasks.create!(params.merge(user: user))
  end

  def self.update_task(task_id, user, params)
    task = Task.find(task_id)
    
    unless task.user_id == user.id
      raise CustomErrors::AuthorizationError.new('タスクの更新権限がありません')
    end
    
    task.update!(params)
    task
  end

  def self.delete_task(task_id, user)
    task = Task.find(task_id)
    
    raise StandardError.new("タスクの削除権限がありません") unless task.user_id == user.id
    
    task.destroy!
  end
end 
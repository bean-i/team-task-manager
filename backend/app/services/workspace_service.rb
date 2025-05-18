class WorkspaceService
  def self.create_workspace(user, params)
    workspace = nil
    
    ActiveRecord::Base.transaction do
      workspace = Workspace.create!(
        title: params[:title]
      )
      
      UsersWorkspace.create!(
        user: user,
        workspace: workspace
      )
    end
    
    workspace
  end

  def self.join_workspace(user, workspace_id)
    workspace = Workspace.find(workspace_id)
    
    return false if UsersWorkspace.exists?(user: user, workspace: workspace)
    
    UsersWorkspace.create!(
      user: user,
      workspace: workspace
    )
    
    true
  end

  def self.list_workspaces(user)
    user.workspaces.includes(:tasks)
  end

  DEFAULT_LIMIT = 10

  def self.get_workspace_details(workspace_id, user, cursor: nil, limit: DEFAULT_LIMIT, filters: {})

    workspace = Workspace.includes(:users).find(workspace_id)
    raise StandardError.new("ワークスペースにアクセスする権限がありません") unless workspace.users.include?(user)
    
    tasks_query = workspace.tasks.includes(:user)
    tasks_query = apply_filters(tasks_query, filters)
    tasks_query = apply_cursor_pagination(tasks_query, cursor)

    tasks = tasks_query
      .order(created_at: :desc, id: :desc)
      .limit(limit + 1)
    
    has_next = tasks.size > limit
    tasks = tasks.take(limit) if has_next
    
    next_cursor = has_next ? encode_cursor(tasks.last) : nil
    
    {
      workspace: workspace,
      tasks: tasks,
      filters: {
        available_categories: Task.categories.keys,
        available_statuses: Task.statuses.keys,
        applied_filters: filters
      },
      pagination: {
        next_cursor: next_cursor,
        has_next: has_next,
        limit: limit
      }
    }
  end

  private

  def self.apply_filters(query, filters)
    query = query.where(status: filters[:status]) if filters[:status].present?
    query = query.where(category: filters[:category]) if filters[:category].present?
    query = query.where(user_id: filters[:user_id]) if filters[:user_id].present?
    query
  end

  def self.apply_cursor_pagination(query, cursor)
    return query if cursor.blank?

    cursor_data = decode_cursor(cursor)
    created_at = cursor_data[:created_at]
    last_id = cursor_data[:id]
    
    query.where('tasks.created_at < ? OR (tasks.created_at = ? AND tasks.id < ?)', 
                created_at, created_at, last_id)
  end

  def self.encode_cursor(task)
    cursor_data = {
      id: task.id,
      created_at: task.created_at
    }
    Base64.strict_encode64(cursor_data.to_json)
  end

  def self.decode_cursor(cursor)
    decoded = Base64.strict_decode64(cursor)
    JSON.parse(decoded, symbolize_names: true)
  end
end 
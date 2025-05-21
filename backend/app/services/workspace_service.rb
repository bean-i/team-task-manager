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
    tasks_query = Task.apply_cursor_pagination(tasks_query, cursor)
    
    tasks = tasks_query
      .order(id: :desc)
      .limit(limit + 1)
    
    has_next = tasks.size > limit
    tasks = tasks.take(limit) if has_next
    
    tasks_json = tasks.map do |task|
      full_name = task.user ? "#{task.user.last_name} #{task.user.first_name}" : ""
      task.as_json.merge('user' => full_name)
    end
    
    next_cursor = has_next ? Task.encode_cursor(tasks.last) : nil
    
    {
      workspace: workspace.as_json(include: { users: { only: [:id, :last_name, :first_name] } }),
      tasks: tasks_json,
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
end 
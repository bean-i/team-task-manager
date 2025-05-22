class WorkspacesController < ApplicationController
  before_action :authenticate_user!

  def index
    workspaces = current_user.workspaces
    render_success(
      message: "ワークスペース一覧を取得しました",
      data: { workspaces: workspaces }
    )
  end

  def show
    result = WorkspaceService.get_workspace_details(
      params[:id],
      current_user,
      cursor: params[:cursor],
      limit: params[:limit] || 10,
      filters: filter_params
    )
    
    render_success(
      message: "ワークスペースの詳細を取得しました",
      data: result
    )
  rescue StandardError => e
    render_error(message: e.message)
  end

  def create
    workspace = Workspace.create!(workspace_params)
    workspace.users << current_user 
    
    render_success(
      message: "ワークスペースを作成しました",
      data: { workspace: workspace },
      status: :created
    )
  rescue StandardError => e
    render_error(message: e.message)
  end

  def join
    workspace = Workspace.find(params[:id])
    workspace.users << current_user
    
    render_success(message: "ワークスペースに参加しました")
  rescue ActiveRecord::RecordNotUnique
    render_error(message: "すでに参加しているワークスペースです")
  rescue StandardError => e
    render_error(message: e.message)
  end

  def progress
    result = WorkspaceService.progress(params[:id], current_user)
    render_success(message: "Progress info", data: result)
  rescue => e
    render_error(message: e.message)
  end

  def member_progress
    result = WorkspaceService.member_progress(params[:id], current_user)
    render_success(message: "Member progress info", data: result)
  rescue => e
    render_error(message: e.message)
  end

  def available
    workspaces = Workspace.where.not(id: current_user.workspaces.select(:id))
    render_success(
      message: "参加可能なワークスペース一覧を取得しました",
      data: { workspaces: workspaces }
    )
  end

  def progress_summary
    workspace = Workspace.find(params[:id])
    aggregation_id = SecureRandom.uuid
    now = Time.current

    total_tasks = workspace.tasks.count
    completed_tasks = workspace.tasks.where(status: 'completed').count
    workspace_percent = total_tasks > 0 ? (completed_tasks * 100 / total_tasks) : 0

    workspace.users.each do |user|
      user_tasks = workspace.tasks.where(user: user)
      total = user_tasks.count
      done = user_tasks.where(status: 'completed').count
      percent = total > 0 ? (done * 100 / total) : 0

      summary = ProgressSummary.create!(
        workspace: workspace,
        user: user,
        total: total,
        done: done,
        percent: percent,
        aggregated_at: now,
        aggregation_id: aggregation_id
      )
    end

    workspace_summary = ProgressSummary.create!(
      workspace: workspace,
      user: nil,
      total: total_tasks,
      done: completed_tasks,
      percent: workspace_percent,
      aggregated_at: now,
      aggregation_id: aggregation_id
    )

    latest = ProgressSummary.where(workspace_id: params[:id]).order(aggregated_at: :desc).select(:aggregation_id, :aggregated_at).first
    summaries = ProgressSummary.where(workspace_id: params[:id], aggregation_id: latest.aggregation_id).includes(:user)

    render_success(
      message: "Progress summary data fetched",
      data: {
        summaries: summaries.map { |s|
          {
            user_id: s.user_id,
            user_name: s.user ? "#{s.user.last_name} #{s.user.first_name}" : "Total",
            done: s.done,
            total: s.total,
            percent: s.percent
          }
        }
      }
    )
  end

  private

  def workspace_params
    params.require(:workspace).permit(:title)
  end

  def filter_params
    params.fetch(:filters, {}).permit(:status, :category, :user_id).to_h
  end
end 
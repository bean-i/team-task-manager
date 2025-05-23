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

  def available
    workspaces = Workspace.where.not(id: current_user.workspaces.select(:id))
    render_success(
      message: "参加可能なワークスペース一覧を取得しました",
      data: { workspaces: workspaces }
    )
  end

  def progress_summary
    workspace = Workspace.find(params[:id])
    latest_agg = ProgressSummary.where(workspace_id: workspace.id).order(aggregated_at: :desc).select(:aggregation_id).first
    summaries = latest_agg ? ProgressSummary.where(workspace_id: workspace.id, aggregation_id: latest_agg.aggregation_id).includes(:user) : []
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
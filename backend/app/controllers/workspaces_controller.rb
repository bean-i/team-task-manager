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
      filters: filter_params.except(:id)
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

  private

  def workspace_params
    params.require(:workspace).permit(:title)
  end

  def filter_params
    params.permit(:status, :category, :user_id).to_h
  end
end 
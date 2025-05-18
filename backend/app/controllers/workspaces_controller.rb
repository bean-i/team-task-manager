class WorkspacesController < ApplicationController
  before_action :authenticate_user!

  def index
    workspaces = WorkspaceService.list_workspaces(current_user)
    
    render_success(
      message: "ワークスペース一覧の取得に成功しました",
      data: { workspaces: workspaces }
    )
  end

  def show
    workspace = WorkspaceService.get_workspace_details(params[:id], current_user)
    
    render_success(
      message: "ワークスペースの詳細取得に成功しました",
      data: { workspace: workspace }
    )
  rescue StandardError => e
    render_error(
      message: e.message,
      status: :forbidden
    )
  end

  def create
    workspace = WorkspaceService.create_workspace(current_user, workspace_params)
    
    render_success(
      message: "ワークスペースを作成しました",
      data: { workspace: workspace },
      status: :created
    )
  rescue StandardError => e
    render_error(
      message: e.message,
      status: :unprocessable_entity
    )
  end

  def join
    success = WorkspaceService.join_workspace(current_user, params[:id])
    
    if success
      render_success(message: "ワークスペースに参加しました")
    else
      render_error(
        message: "すでに参加しているワークスペースです",
        status: :unprocessable_entity
      )
    end
  end

  private

  def workspace_params
    params.require(:workspace).permit(:title)
  end
end 
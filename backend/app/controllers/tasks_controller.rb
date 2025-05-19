class TasksController < ApplicationController
  before_action :authenticate_user!

  def create
    task = TaskService.create_task(
      params[:workspace_id],
      current_user,
      task_params
    )
    
    render_success(
      message: "タスクを作成しました",
      data: { task: task },
      status: :created
    )
  rescue StandardError => e
    render_error(
      message: e.message,
      status: :unprocessable_entity
    )
  end

  def update
    task = TaskService.update_task(
      params[:id],
      current_user,
      task_params
    )
    
    render_success(
      message: "タスクを更新しました",
      data: { task: task }
    )
  rescue StandardError => e
    render_error(
      message: e.message,
      status: :unprocessable_entity
    )
  end

  def destroy
    TaskService.delete_task(params[:id], current_user)
    
    render_success(message: "タスクを削除しました")
  rescue StandardError => e
    render_error(
      message: e.message,
      status: :unprocessable_entity
    )
  end

  private

  def task_params
    params.require(:task).permit(:title, :status, :category)
  end
end 
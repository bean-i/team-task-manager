require 'rails_helper'

RSpec.describe 'タスクAPI', type: :request do
  let!(:user) { User.create!(first_name: 'テスト', last_name: 'ユーザー', email: 'task@example.com', password: 'Test123!') }
  let!(:workspace) { Workspace.create!(title: 'タスク用ワークスペース', users: [user]) }
  let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base, 'HS256') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST /workspaces/:workspace_id/tasks' do
    it '正しい情報でタスクを作成できる' do
      post "/workspaces/#{workspace.id}/tasks", params: { task: { title: '新しいタスク', user_id: user.id, status: 'not_started', category: 'frontend' } }, headers: headers
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end
  end

  describe 'PATCH /workspaces/:workspace_id/tasks/:id' do
    let!(:task) { Task.create!(title: '修正前タスク', workspace: workspace, user: user, status: 'not_started', category: 'frontend') }
    it 'タスクを修正できる' do
      patch "/workspaces/#{workspace.id}/tasks/#{task.id}", params: { task: { title: '修正後タスク', user_id: user.id, status: 'not_started', category: 'frontend' } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end
  end
end 
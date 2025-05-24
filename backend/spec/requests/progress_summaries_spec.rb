require 'rails_helper'

RSpec.describe '進捗率API', type: :request do
  let!(:user) { User.create!(first_name: 'テスト', last_name: 'ユーザー', email: 'progress@example.com', password: 'Test123!') }
  let!(:workspace) { Workspace.create!(title: '進捗率用ワークスペース', users: [user]) }
  let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base, 'HS256') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  before do
    ProgressSummary.create!(workspace: workspace, user: nil, total: 10, done: 5, percent: 50, aggregated_at: Time.current, aggregation_id: 'abc')
  end

  describe 'GET /workspaces/:id/progress_summary' do
    it '認証済みユーザーは進捗率集計結果を取得できる' do
      get "/workspaces/#{workspace.id}/progress_summary", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end

    it '認証なしでは進捗率集計結果を取得できない' do
      get "/workspaces/#{workspace.id}/progress_summary"
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['status']).to eq('error')
    end
  end
end 
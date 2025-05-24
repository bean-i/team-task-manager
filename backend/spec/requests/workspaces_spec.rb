require 'rails_helper'

RSpec.describe 'ワークスペースAPI', type: :request do
  let!(:user) { User.create!(first_name: 'テスト', last_name: 'ユーザー', email: 'ws@example.com', password: 'Test123!') }
  let(:token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, Rails.application.credentials.secret_key_base, 'HS256') }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST /workspaces' do
    it '正しい情報でワークスペースを作成できる' do
      post '/workspaces', params: { workspace: { title: 'テストワークスペース' } }, headers: headers
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end
  end

  describe 'GET /workspaces' do
    before do
      Workspace.create!(title: 'A', users: [user])
      Workspace.create!(title: 'B', users: [user])
    end
    it '自分が参加しているワークスペース一覧を取得できる' do
      get '/workspaces', headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
      expect(json['data']['workspaces'].size).to be >= 2
    end
  end
end 
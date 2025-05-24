require 'rails_helper'

RSpec.describe 'ユーザーAPI', type: :request do
  describe 'POST /signup' do
    it '正しい情報でサインアップできる' do
      post '/signup', params: { user: { first_name: 'テスト', last_name: 'ユーザー', email: 'test@example.com', password: 'Test123!' } }
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end
  end

  describe 'POST /login' do
    let!(:user) { User.create!(first_name: 'テスト', last_name: 'ユーザー', email: 'login@example.com', password: 'Test123!') }

    it '正しい情報でログインできる' do
      post '/login', params: { user: { email: 'login@example.com', password: 'Test123!' } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['status']).to eq('success')
    end

    it '間違ったパスワードではログインできない' do
      post '/login', params: { user: { email: 'login@example.com', password: 'WrongPass1!' } }
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['status']).to eq('error')
    end
  end
end 
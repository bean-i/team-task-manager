require 'rails_helper'

RSpec.describe Workspace, type: :model do
  it 'タイトルがない場合は無効である' do
    workspace = Workspace.new(title: nil)
    expect(workspace).not_to be_valid
  end

  it 'ユーザーとの関連付けが正しく動作する' do
    user = User.create!(first_name: 'テスト', last_name: 'ユーザー', email: 'test2@example.com', password: 'Password1!')
    workspace = Workspace.create!(title: 'テストワークスペース')
    workspace.users << user
    expect(workspace.users).to include(user)
  end
end 
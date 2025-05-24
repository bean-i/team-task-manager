require 'rails_helper'

RSpec.describe Task, type: :model do
  it 'タイトルがない場合は無効である' do
    task = Task.new(title: nil)
    expect(task).not_to be_valid
  end

  it 'ステータスが許可された値でない場合はエラーが発生する' do
    expect {
      Task.new(title: 'テスト', status: 'invalid_status')
    }.to raise_error(ArgumentError)
  end
end 
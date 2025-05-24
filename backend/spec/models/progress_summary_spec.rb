require 'rails_helper'

RSpec.describe ProgressSummary, type: :model do
  it 'percentが0〜100の範囲外の場合は無効である' do
    summary = ProgressSummary.new(percent: 150)
    expect(summary).not_to be_valid
  end

  it 'user_idがnilでも全体進捗率として有効である' do
    workspace = Workspace.create!(title: 'テストワークスペース')
    summary = ProgressSummary.new(user_id: nil, percent: 50, total: 10, done: 5, workspace_id: workspace.id, aggregation_id: 'abc', aggregated_at: Time.current)
    expect(summary).to be_valid
  end
end

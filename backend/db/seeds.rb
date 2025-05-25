User.destroy_all
Workspace.destroy_all
Task.destroy_all

users = [
  User.create!(first_name: '太郎', last_name: '山田', email: 'taro@example.com', password: 'Password1!'),
  User.create!(first_name: '花子', last_name: '佐藤', email: 'hanako@example.com', password: 'Password2!'),
  User.create!(first_name: '健一', last_name: '鈴木', email: 'kenichi@example.com', password: 'Password3!')
]

taro = users[0]
workspaces = [
  Workspace.create!(title: '開発チーム'),
  Workspace.create!(title: 'デザインチーム'),
  Workspace.create!(title: '営業チーム')
]

categories = %w[企画 デザイン バックエンド フロントエンド テスト]
statuses = %w[未着手 進行中 完了]

workspaces.each do |ws|
  30.times do |i|
    user = if ws.title == '営業チーム'
      users[1..2].sample
    else
      users.sample
    end
    Task.create!(
      title: "タスク#{i + 1} (#{ws.title})",
      category: categories.sample,
      status: statuses.sample,
      user: user,
      workspace: ws
    )
    ws.users << user unless ws.users.include?(user)
  end
end

puts 'Seed data loaded!'

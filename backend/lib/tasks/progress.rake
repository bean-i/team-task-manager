namespace :progress do
  desc "担当者ごとの進捗率を集計する"
  task aggregate: :environment do
    Workspace.find_each do |ws|
      ws.users.each do |user|
        total = ws.tasks.where(user: user).count
        done = ws.tasks.where(user: user, status: 'completed').count
        percent = total > 0 ? (done * 100 / total) : 0
        ProgressSummary.create!(
          workspace: ws,
          user: user,
          total: total,
          done: done,
          percent: percent,
          aggregated_at: Time.current
        )
      end
    end
    puts "進捗率集計が完了しました！"
  end
end 
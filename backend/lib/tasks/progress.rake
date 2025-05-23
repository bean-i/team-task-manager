namespace :progress do
  desc "担当者ごとの進捗率と全体進捗率を集計する"
  task aggregate: :environment do
    require 'securerandom'
    now = Time.current

    Workspace.find_each do |ws|
      aggregation_id = SecureRandom.uuid

      # total
      total_tasks = ws.tasks.count
      done_tasks = ws.tasks.where(status: 'completed').count
      percent = total_tasks > 0 ? (done_tasks * 100 / total_tasks) : 0
      ProgressSummary.create!(
        workspace: ws,
        user: nil,
        total: total_tasks,
        done: done_tasks,
        percent: percent,
        aggregated_at: now,
        aggregation_id: aggregation_id
      )

      # member
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
          aggregated_at: now,
          aggregation_id: aggregation_id
        )
      end
    end
    puts "[#{Time.current.strftime('%Y-%m-%d %H:%M:%S')}] 進捗率集計が完了しました！"
  end
end 
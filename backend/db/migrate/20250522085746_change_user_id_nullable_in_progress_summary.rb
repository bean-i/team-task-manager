class ChangeUserIdNullableInProgressSummary < ActiveRecord::Migration[6.1]
  def change
    change_column_null :progress_summaries, :user_id, true
  end
end

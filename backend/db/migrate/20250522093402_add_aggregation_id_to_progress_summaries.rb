class AddAggregationIdToProgressSummaries < ActiveRecord::Migration[6.1]
  def change
    add_column :progress_summaries, :aggregation_id, :string
    add_index :progress_summaries, [:workspace_id, :aggregation_id]
  end
end

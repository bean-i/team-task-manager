class CreateProgressSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :progress_summaries do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :total
      t.integer :done
      t.integer :percent
      t.datetime :aggregated_at

      t.timestamps
    end
  end
end

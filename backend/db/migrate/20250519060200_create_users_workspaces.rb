class CreateUsersWorkspaces < ActiveRecord::Migration[8.0]
  def change
    create_table :users_workspaces do |t|
      t.references :user, null: false, foreign_key: true
      t.references :workspace, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :users_workspaces, [:user_id, :workspace_id], unique: true
  end
end

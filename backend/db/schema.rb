# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_22_093402) do
  create_table "progress_summaries", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "user_id"
    t.integer "total"
    t.integer "done"
    t.integer "percent"
    t.datetime "aggregated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aggregation_id"
    t.index ["user_id"], name: "index_progress_summaries_on_user_id"
    t.index ["workspace_id", "aggregation_id"], name: "index_progress_summaries_on_workspace_id_and_aggregation_id"
    t.index ["workspace_id"], name: "index_progress_summaries_on_workspace_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.string "status", null: false
    t.string "category", null: false
    t.integer "user_id", null: false
    t.integer "workspace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tasks_on_user_id"
    t.index ["workspace_id"], name: "index_tasks_on_workspace_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users_workspaces", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "workspace_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "workspace_id"], name: "index_users_workspaces_on_user_id_and_workspace_id", unique: true
    t.index ["user_id"], name: "index_users_workspaces_on_user_id"
    t.index ["workspace_id"], name: "index_users_workspaces_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "progress_summaries", "users"
  add_foreign_key "progress_summaries", "workspaces"
  add_foreign_key "tasks", "users"
  add_foreign_key "tasks", "workspaces"
  add_foreign_key "users_workspaces", "users"
  add_foreign_key "users_workspaces", "workspaces"
end

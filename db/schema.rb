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

ActiveRecord::Schema[7.1].define(version: 2024_10_10_115034) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "accesses", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "role_id", null: false
    t.uuid "user_id", null: false
    t.text "justification"
    t.datetime "expires_at"
    t.string "approvals", default: [], array: true
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "requestor_id"
  end

  create_table "approval_workflows", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audit_logs", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "event_type", null: false
    t.text "event_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "system_id"
    t.index ["system_id"], name: "index_audit_logs_on_system_id"
  end

  create_table "autoapproval_workflows", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "autodenial_workflows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "system_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_id"], name: "index_permissions_on_system_id"
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "provision_workflows", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "system_id", null: false
    t.integer "term"
    t.jsonb "approval_workflow_properties", default: {}
    t.jsonb "provision_workflow_properties", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "autoapproval_workflow_properties", default: {}
    t.uuid "approval_workflow_id"
    t.uuid "autoapproval_workflow_id"
    t.uuid "provision_workflow_id"
    t.boolean "is_active", default: true
    t.uuid "autodenial_workflow_id"
    t.jsonb "autodenial_workflow_properties", default: {}
  end

  create_table "systems", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_tokens_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "public.gen_random_uuid()" }, force: :cascade do |t|
    t.string "displayname", null: false
    t.string "username", null: false
    t.string "dn"
    t.string "email"
    t.string "position"
    t.string "team"
    t.string "company"
    t.uuid "manager_id"
    t.boolean "is_admin", default: false
    t.boolean "is_service", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: false
    t.text "sshkey"
    t.string "uid_number"
    t.string "home_directory"
    t.string "login_shell"
    t.boolean "is_deactivated", default: false
  end

  add_foreign_key "audit_logs", "systems"
  add_foreign_key "permissions", "systems"
  add_foreign_key "permissions", "users"
  add_foreign_key "tokens", "users"
end

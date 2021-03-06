class First < ActiveRecord::Migration
  def up
    create_table "account_sessions", force: :cascade do |t|
      t.integer  "buy_count",  default: 0
      t.integer  "sell_count", default: 0
      t.text     "payload"
      t.integer  "status",     default: 0
      t.integer  "account_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "account_sessions", ["account_id"], name: "index_account_sessions_on_account_id", using: :btree

    create_table "account_templates", force: :cascade do |t|
      t.integer "min_market_volume"
      t.integer "min_sell_percent_diff"
      t.integer "min_sell_percent_stop"
      t.integer "min_buy_sth_diff"
      t.integer "min_buy_percent_diff"
      t.decimal "min_buy_price"
      t.integer "interval"
      t.integer "account_id"
    end

    add_index "account_templates", ["account_id"], name: "index_account_templates_on_account_id", using: :btree

    create_table "accounts", force: :cascade do |t|
      t.string  "key"
      t.string  "secret"
      t.integer "provider"
      t.integer "user_id"
    end

    add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

    create_table "orders", force: :cascade do |t|
      t.string   "type"
      t.string   "market"
      t.decimal  "quantity"
      t.decimal  "price"
      t.decimal  "commission"
      t.string   "uuid"
      t.integer  "status",     default: 0
      t.integer  "session_id"
      t.integer  "account_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "orders", ["account_id"], name: "index_orders_on_account_id", using: :btree
    add_index "orders", ["session_id"], name: "index_orders_on_session_id", using: :btree
    add_index "orders", ["uuid"], name: "index_orders_on_uuid", using: :btree

    create_table "users", force: :cascade do |t|
      t.string   "email",                  default: "", null: false
      t.string   "encrypted_password",     default: "", null: false
      t.string   "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer  "sign_in_count",          default: 0,  null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet     "current_sign_in_ip"
      t.inet     "last_sign_in_ip"
      t.datetime "created_at",                          null: false
      t.datetime "updated_at",                          null: false
    end

    add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
    add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  def down
    drop_table :orders
    drop_table :account_sessions
    drop_table :account_templates
    drop_table :accounts
    drop_table :users
  end
end

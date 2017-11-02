# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171031150427) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_reports", force: :cascade do |t|
    t.integer  "account_template_id"
    t.integer  "type",                default: 0
    t.decimal  "balance",             default: 0.0
    t.decimal  "profit",              default: 0.0
    t.string   "currency"
    t.string   "strategy"
    t.date     "datetime"
    t.text     "payload"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "account_reports", ["account_template_id"], name: "index_account_reports_on_account_template_id", using: :btree

  create_table "account_sessions", force: :cascade do |t|
    t.integer  "buy_count",           default: 0
    t.integer  "sell_count",          default: 0
    t.text     "payload"
    t.integer  "status",              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_template_id"
    t.string   "strategy"
  end

  create_table "account_templates", force: :cascade do |t|
    t.decimal  "min_market_volume"
    t.decimal  "min_sell_percent_diff"
    t.decimal  "min_sell_percent_stop"
    t.decimal  "min_buy_sth_diff"
    t.decimal  "min_buy_percent_diff"
    t.decimal  "min_buy_price"
    t.integer  "account_id"
    t.decimal  "min_pump_risk_percent", default: 5.0
    t.text     "black_list"
    t.text     "white_list"
    t.decimal  "white_list_coef"
    t.string   "currency"
    t.integer  "interval",              default: 600
    t.integer  "strategy",              default: 0
    t.datetime "last_time"
    t.decimal  "max_buy_percent_diff",  default: 4.0
  end

  add_index "account_templates", ["account_id"], name: "index_account_templates_on_account_id", using: :btree

  create_table "account_wallets", force: :cascade do |t|
    t.string  "currency"
    t.decimal "available"
    t.decimal "available_btc"
    t.integer "account_id"
  end

  add_index "account_wallets", ["account_id"], name: "index_account_wallets_on_account_id", using: :btree

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
    t.integer  "status",              default: 0
    t.integer  "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reason"
    t.decimal  "profit"
    t.decimal  "spread"
    t.decimal  "volume"
    t.datetime "closed_at"
    t.integer  "sell_count"
    t.integer  "buy_count"
    t.decimal  "yesterday_price"
    t.string   "chain_id"
    t.integer  "account_template_id"
    t.text     "template_data"
  end

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

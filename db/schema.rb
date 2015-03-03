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

ActiveRecord::Schema.define(version: 20150220120643) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string   "tax_id"
    t.string   "name"
    t.string   "description"
    t.string   "processing_unit"
    t.string   "accounting_service"
    t.string   "management_unit"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "customers", ["tax_id"], name: "index_customers_on_tax_id", unique: true, using: :btree

  create_table "invoice_logs", force: :cascade do |t|
    t.integer  "invoice_id"
    t.string   "action"
    t.integer  "action_code", default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "invoice_logs", ["invoice_id", "id"], name: "index_invoice_logs_on_invoice_id_and_id", order: {"id"=>:desc}, using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "issuer_id"
    t.integer  "customer_id"
    t.string   "invoice_serie",                          default: ""
    t.string   "invoice_num"
    t.date     "invoice_date"
    t.string   "subject"
    t.decimal  "amount",        precision: 11, scale: 2, default: 0.0
    t.text     "csv"
    t.text     "xml"
    t.text     "xsig"
    t.boolean  "is_converted",                           default: false
    t.boolean  "is_signed",                              default: false
    t.boolean  "is_presented",                           default: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  add_index "invoices", ["issuer_id", "customer_id", "invoice_serie", "invoice_num"], name: "ix_customer", using: :btree
  add_index "invoices", ["issuer_id", "invoice_date", "invoice_serie", "invoice_num"], name: "ix_date", order: {"invoice_date"=>:desc}, using: :btree
  add_index "invoices", ["issuer_id", "invoice_serie", "invoice_num", "id"], name: "ix_serie_num", using: :btree
  add_index "invoices", ["issuer_id"], name: "index_invoices_on_issuer_id", using: :btree

  create_table "issuers", force: :cascade do |t|
    t.string   "tax_id"
    t.string   "company_name",        default: ""
    t.string   "trade_name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "person_type_code",    default: "J"
    t.string   "residence_type_code", default: "R"
    t.string   "address"
    t.string   "postal_code"
    t.string   "town"
    t.string   "province"
    t.string   "country_code",        default: "ESP"
    t.text     "certificate"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "issuers", ["tax_id"], name: "index_issuers_on_tax_id", unique: true, using: :btree

end

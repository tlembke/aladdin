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

ActiveRecord::Schema.define(version: 20201214035646) do

  create_table "cells", force: :cascade do |t|
    t.integer  "register_id"
    t.integer  "patient_id"
    t.integer  "header_id"
    t.string   "value"
    t.date     "date"
    t.text     "note"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.text     "chapter"
    t.integer  "section_id"
    t.integer  "sort"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "check",      default: false, null: false
  end

  create_table "consults", force: :cascade do |t|
    t.integer  "provider_id"
    t.integer  "patient_id"
    t.datetime "consultdate"
    t.string   "mbs"
    t.string   "consulttype"
    t.text     "notes"
    t.boolean  "billed"
    t.boolean  "complete"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "fullname"
    t.string   "providername"
    t.string   "billingnote"
    t.integer  "consulttime"
    t.integer  "delivery"
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "fax"
    t.boolean  "favourite"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "docs", force: :cascade do |t|
    t.string   "name"
    t.string   "filename"
    t.string   "thumbnail"
    t.text     "description"
    t.integer  "cat"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "docs_tags", id: false, force: :cascade do |t|
    t.integer "doc_id", null: false
    t.integer "tag_id", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "patient_id",  default: 0
    t.integer  "code"
    t.integer  "parent"
    t.string   "texttype"
    t.text     "content"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "goals", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "condition_id"
    t.integer  "patient_id"
    t.integer  "measure_id"
    t.integer  "active"
    t.integer  "parent"
    t.integer  "master_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.decimal  "target"
    t.string   "autoload"
    t.text     "by"
    t.text     "fallback1"
    t.text     "fallback2"
    t.boolean  "priority"
  end

  create_table "headers", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.boolean  "special"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "register_id"
    t.integer  "sort"
    t.string   "keyword"
  end

  create_table "images", force: :cascade do |t|
    t.text     "image_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "itemnumbers", force: :cascade do |t|
    t.string   "name"
    t.string   "mbs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "sort"
  end

  create_table "masters", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measurements", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "measure_id"
    t.integer  "value"
    t.date     "measuredate"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "measures", force: :cascade do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.string   "description"
    t.string   "units"
    t.decimal  "target"
    t.integer  "operator"
    t.integer  "places"
    t.boolean  "local"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "scale"
    t.string   "field"
  end

  create_table "members", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "genie_id"
    t.text     "note"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "year_reset"
    t.integer  "epc"
    t.integer  "everyNumber"
    t.string   "everyUnit"
    t.integer  "nextDay"
    t.integer  "nextMonth"
    t.integer  "nextYear"
    t.boolean  "exactDate"
    t.boolean  "recallflag",  default: false, null: false
  end

  create_table "paragraphs", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "chapter_id"
    t.text     "paragraph"
    t.boolean  "show"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patient_recalls", force: :cascade do |t|
    t.integer  "recall_id"
    t.integer  "patient_id"
    t.integer  "everyNumber"
    t.string   "everyUnit"
    t.integer  "nextDay"
    t.integer  "nextMonth"
    t.integer  "nextYear"
    t.boolean  "exactDate"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "phonetimes", force: :cascade do |t|
    t.integer  "doctor_id"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prefs", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recalls", force: :cascade do |t|
    t.text     "title"
    t.integer  "cat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "register_patients", force: :cascade do |t|
    t.integer  "register_id"
    t.integer  "patient_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "registers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "loaded"
    t.integer  "code",       default: 0, null: false
  end

  create_table "results", force: :cascade do |t|
    t.date     "result_date"
    t.integer  "result_id"
    t.boolean  "printed"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "patient_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "progress"
    t.integer  "patient_id"
    t.integer  "condition_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

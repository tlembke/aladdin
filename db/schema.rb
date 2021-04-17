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

ActiveRecord::Schema.define(version: 20210410122827) do

  create_table "bookers", force: :cascade do |t|
    t.integer  "clinic_id"
    t.integer  "genie"
    t.string   "surname"
    t.string   "firstname"
    t.date     "dob"
    t.string   "vaxtype"
    t.integer  "contactby"
    t.boolean  "confirm"
    t.datetime "received"
    t.integer  "arm"
    t.integer  "dose"
    t.string   "batch"
    t.string   "note"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "bookhour"
    t.integer  "bookminute"
    t.integer  "eligibility"
  end

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

  create_table "clinics", force: :cascade do |t|
    t.date     "clinicdate"
    t.integer  "starthour",    default: 10
    t.integer  "startminute",  default: 0
    t.integer  "finishhour",   default: 13
    t.integer  "finishminute", default: 0
    t.integer  "perhour",      default: 0
    t.string   "vaxtype",      default: "Flu"
    t.string   "venue",        default: "Baptist Hall"
    t.boolean  "template",     default: false
    t.integer  "age",          default: 0
    t.integer  "ATSIage",      default: 0
    t.boolean  "chronic",      default: false
    t.integer  "chronicage",   default: 0
    t.string   "message"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "people",       default: 25
    t.boolean  "live"
    t.boolean  "healthcare"
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
    t.integer  "doc_id"
  end

  create_table "goals", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "condition_id"
    t.integer  "patient_id"
    t.integer  "measure_id"
    t.integer  "active"
    t.integer  "parent"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "master_id"
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

  create_table "providers", force: :cascade do |t|
    t.integer  "genie_id"
    t.integer  "type"
    t.string   "name"
    t.boolean  "online",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
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

  create_table "slots", force: :cascade do |t|
    t.datetime "appointment"
    t.integer  "doctor_id"
    t.integer  "patient_id"
    t.string   "patient_name"
    t.string   "apptype"
    t.boolean  "available"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "appt_id"
    t.integer  "block_id"
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

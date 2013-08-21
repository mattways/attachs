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

ActiveRecord::Schema.define(version: 20130820222534) do

  create_table "all_attacheds", force: true do |t|
    t.string   "image"
    t.string   "file_presence"
    t.string   "file_content_type"
    t.string   "file_size"
    t.string   "file_all"
    t.string   "file_default"
    t.string   "image_presence"
    t.string   "image_content_type"
    t.string   "image_size"
    t.string   "image_all"
    t.string   "image_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_attacheds", force: true do |t|
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "image_attacheds", force: true do |t|
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120905181425) do

  create_table "audios", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "filename",     :null => false
    t.string   "mime",         :null => false
    t.integer  "size",         :null => false
    t.integer  "audible_id",   :null => false
    t.string   "audible_type", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "audios", ["audible_id"], :name => "index_audios_on_audible_id"
  add_index "audios", ["audible_type"], :name => "index_audios_on_audible_type"
  add_index "audios", ["created_at"], :name => "index_audios_on_created_at"
  add_index "audios", ["filename"], :name => "index_audios_on_filename"
  add_index "audios", ["mime"], :name => "index_audios_on_mime"
  add_index "audios", ["name"], :name => "index_audios_on_name"
  add_index "audios", ["size"], :name => "index_audios_on_size"
  add_index "audios", ["updated_at"], :name => "index_audios_on_updated_at"

  create_table "images", :force => true do |t|
    t.string   "filename",       :null => false
    t.string   "mime",           :null => false
    t.integer  "size",           :null => false
    t.integer  "imageable_id",   :null => false
    t.string   "imageable_type", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "images", ["created_at"], :name => "index_images_on_created_at"
  add_index "images", ["filename"], :name => "index_images_on_filename"
  add_index "images", ["imageable_id"], :name => "index_images_on_imageable_id"
  add_index "images", ["imageable_type"], :name => "index_images_on_imageable_type"
  add_index "images", ["mime"], :name => "index_images_on_mime"
  add_index "images", ["size"], :name => "index_images_on_size"
  add_index "images", ["updated_at"], :name => "index_images_on_updated_at"

  create_table "videos", :force => true do |t|
    t.string   "youtube_url",   :null => false
    t.string   "youtube_id",    :null => false
    t.integer  "videable_id",   :null => false
    t.string   "videable_type", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "videos", ["created_at"], :name => "index_videos_on_created_at"
  add_index "videos", ["updated_at"], :name => "index_videos_on_updated_at"
  add_index "videos", ["videable_id"], :name => "index_videos_on_videable_id"
  add_index "videos", ["videable_type"], :name => "index_videos_on_videable_type"
  add_index "videos", ["youtube_id"], :name => "index_videos_on_youtube_id"
  add_index "videos", ["youtube_url"], :name => "index_videos_on_youtube_url"

end

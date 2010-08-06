# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100723080526) do

  create_table "animes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "poster_url"
    t.string   "permalink"
    t.integer  "episodes_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "anidb_id"
    t.string   "poster_file_name"
    t.string   "poster_content_type"
    t.integer  "poster_file_size"
    t.datetime "poster_updated_at"
    t.boolean  "hentai",              :default => false
    t.string   "trailer_url"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "episodes", :force => true do |t|
    t.integer  "number"
    t.string   "title"
    t.integer  "anime_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "season",      :default => 0
    t.text     "description"
    t.date     "airdate"
  end

  create_table "links", :force => true do |t|
    t.string   "url"
    t.integer  "episode_id"
    t.integer  "prev_part_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.string   "url"
    t.string   "parser"
    t.datetime "latest_update"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggables", :force => true do |t|
    t.integer  "anime_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taggables_count", :default => 0
    t.string   "permalink"
  end

  create_table "titles", :force => true do |t|
    t.string   "name"
    t.integer  "anidb_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "main"
    t.string   "hashed_name"
  end

end

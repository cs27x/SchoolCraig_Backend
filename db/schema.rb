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

ActiveRecord::Schema.define(version: 20141201232913) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "categories", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string "name"
  end

  create_table "posts", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.datetime "date",                   default: "now()"
    t.text     "description"
    t.uuid     "category_id"
    t.integer  "cost"
    t.string   "title",       limit: 64
  end

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string  "fname"
    t.string  "lname"
    t.string  "email"
    t.string  "password",  limit: 64
    t.string  "salt",      limit: 32
    t.boolean "activated"
  end

end

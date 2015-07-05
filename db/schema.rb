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

ActiveRecord::Schema.define(version: 20150703122330) do

  create_table "comments", force: :cascade do |t|
    t.text     "comment",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "author_id",  limit: 4
    t.integer  "post_id",    limit: 4
  end

  add_index "comments", ["author_id"], name: "index_comments_on_author_id", using: :btree
  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree

  create_table "comments_tags", force: :cascade do |t|
    t.integer "comment_id", limit: 4
    t.integer "tag_id",     limit: 4
  end

  add_index "comments_tags", ["comment_id"], name: "index_comments_tags_on_comment_id", using: :btree
  add_index "comments_tags", ["tag_id"], name: "index_comments_tags_on_tag_id", using: :btree

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "post_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "likes", ["post_id"], name: "index_likes_on_post_id", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "image",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "author_id",   limit: 4
  end

  add_index "posts", ["author_id"], name: "index_posts_on_author_id", using: :btree

  create_table "posts_tags", force: :cascade do |t|
    t.integer "post_id", limit: 4
    t.integer "tag_id",  limit: 4
  end

  add_index "posts_tags", ["post_id"], name: "index_posts_tags_on_post_id", using: :btree
  add_index "posts_tags", ["tag_id"], name: "index_posts_tags_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "text",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_followings", force: :cascade do |t|
    t.integer "user_id",      limit: 4
    t.integer "following_id", limit: 4
  end

  add_index "user_followings", ["following_id"], name: "index_user_followings_on_following_id", using: :btree
  add_index "user_followings", ["user_id"], name: "index_user_followings_on_user_id", using: :btree

  create_table "user_tags", force: :cascade do |t|
    t.integer "post_id",    limit: 4
    t.integer "user_id",    limit: 4
    t.integer "comment_id", limit: 4
  end

  add_index "user_tags", ["comment_id"], name: "index_user_tags_on_comment_id", using: :btree
  add_index "user_tags", ["post_id"], name: "index_user_tags_on_post_id", using: :btree
  add_index "user_tags", ["user_id"], name: "index_user_tags_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",         limit: 255
    t.string   "email",            limit: 255
    t.date     "birthdate"
    t.text     "description",      limit: 65535
    t.string   "gender",           limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "token",            limit: 255
    t.string   "password_digest",  limit: 255
    t.integer  "followings_count", limit: 4,     default: 0
    t.integer  "followers_count",  limit: 4,     default: 0
  end

end

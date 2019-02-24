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

ActiveRecord::Schema.define(version: 20190222043222) do

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "uniq_id"
    t.string "crawl_timestamp"
    t.string "product_url"
    t.string "product_name"
    t.string "product_category_tree"
    t.string "pid"
    t.string "retail_price"
    t.string "discounted_price"
    t.string "image"
    t.string "is_FK_Advantage_product"
    t.string "description"
    t.string "product_rating"
    t.string "overall_rating"
    t.string "brand"
    t.string "product_specifications"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

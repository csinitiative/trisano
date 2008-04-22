# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 30) do

  create_table "answer_sets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_id"
  end

  create_table "answers", :force => true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "answer_set_id"
    t.integer  "position"
  end

  create_table "cmrs", :force => true do |t|
    t.string   "name"
    t.integer  "disease_id"
    t.integer  "jurisdiction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diseases", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "program_id"
  end

  create_table "form_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forms", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "jurisdiction_id"
    t.integer  "disease_id"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_template"
    t.integer  "template_form_id"
    t.integer  "form_status_id"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "section_id"
  end

  create_table "jurisdictions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "programs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "html_form_type"
    t.boolean  "has_answer_set"
  end

  create_table "questions", :force => true do |t|
    t.string   "text"
    t.string   "help"
    t.integer  "question_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "position"
    t.string   "condition"
    t.integer  "follow_up_group_id"
  end

  create_table "responses", :force => true do |t|
    t.integer  "cmr_id"
    t.integer  "form_id"
    t.integer  "question_id"
    t.string   "response"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "form_template_id"
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.integer  "form_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

end

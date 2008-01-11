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

ActiveRecord::Schema.define(:version => 7) do

  create_table "cmrs", :force => true do |t|
    t.string   "accession_number",       :limit => 100, :default => "", :null => false
    t.string   "entered_by",             :limit => 10,  :default => "", :null => false
    t.date     "onset_date"
    t.string   "clinician_name",         :limit => 40
    t.string   "clinician_phone_number", :limit => 20
    t.string   "patient_hospitalized",   :limit => 1
    t.string   "hospitals",              :limit => 100
    t.string   "did_patient_die",        :limit => 1
    t.date     "expired_date"
    t.string   "reported_by",            :limit => 40
    t.date     "reported_date"
    t.string   "lhd_investigator",       :limit => 40
    t.string   "reporting_phone_number", :limit => 20
    t.string   "lhd_reviewed_by",        :limit => 40
    t.date     "lhd_reviewed_date"
    t.string   "case_classification",    :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "disease_id"
    t.integer  "patient_id"
  end

  create_table "diseases", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ethnicities", :force => true do |t|
    t.string "ethnic_group", :limit => 30
  end

  create_table "patients", :force => true do |t|
    t.string   "last_name",                 :limit => 25, :null => false
    t.string   "first_name",                :limit => 25
    t.string   "middle_name",               :limit => 25
    t.date     "date_of_birth"
    t.string   "street_address",            :limit => 55
    t.string   "city",                      :limit => 40
    t.string   "county",                    :limit => 40
    t.string   "country",                   :limit => 40
    t.string   "state",                     :limit => 2
    t.string   "zip_code",                  :limit => 10
    t.string   "phone_1",                   :limit => 20
    t.string   "phone_2",                   :limit => 20
    t.string   "phone_3",                   :limit => 20
    t.string   "sex",                       :limit => 1
    t.integer  "race_id"
    t.integer  "ethnicity_id"
    t.integer  "language_id"
    t.string   "primary_language_if_other", :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

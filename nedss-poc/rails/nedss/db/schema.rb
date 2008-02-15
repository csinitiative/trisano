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

ActiveRecord::Schema.define(:version => 10) do

  create_table "addresses", :force => true do |t|
    t.integer  "location_id"
    t.integer  "city_id"
    t.integer  "county_id"
    t.integer  "district_id"
    t.integer  "state_id"
    t.string   "street_number", :limit => 10
    t.string   "street_name",   :limit => 50
    t.string   "unit_number",   :limit => 10
    t.string   "postal_code",   :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "animals", :force => true do |t|
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cases_events", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clinicals", :force => true do |t|
    t.integer  "event_id"
    t.integer  "test_public_health_lab_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clusters", :force => true do |t|
    t.integer  "primary_event_id"
    t.integer  "secondary_event_id"
    t.integer  "cluster_status_id"
    t.string   "comment",            :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "codes", :force => true do |t|
    t.string "code_name",        :limit => 50
    t.string "the_code",         :limit => 20
    t.string "code_description", :limit => 100
  end

  create_table "disease_events", :force => true do |t|
    t.integer  "event_id"
    t.integer  "disease_id"
    t.integer  "hospitalized_id"
    t.integer  "died_id"
    t.integer  "pregnant_id"
    t.date     "disease_onset_date"
    t.date     "date_diagnosed"
    t.date     "pregnancy_due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "diseases", :force => true do |t|
    t.string "disease_name", :limit => 50
  end

  create_table "encounters", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", :force => true do |t|
    t.string   "record_number",     :limit => 20
    t.string   "entity_url_number", :limit => 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entity_type"
  end

  create_table "entities_locations", :force => true do |t|
    t.integer  "location_id"
    t.integer  "entity_id"
    t.integer  "entity_location_type_id"
    t.integer  "primary_yn_id"
    t.string   "comment",                 :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entity_groups", :force => true do |t|
    t.integer  "entity_group_type_id"
    t.integer  "primary_entity_id"
    t.integer  "secondary_entity_id"
    t.string   "entity_group_name",    :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "event_type_id"
    t.integer  "event_status_id"
    t.integer  "imported_from_id"
    t.integer  "event_case_status_id"
    t.string   "event_name",                         :limit => 100
    t.date     "event_onset_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "outbreak_associated_id"
    t.string   "outbreak_name"
    t.integer  "investigation_LHD_status_id"
    t.datetime "investigation_started_date"
    t.datetime "investigation_completed_LHD_date"
    t.datetime "review_completed_UDOH_date"
    t.datetime "first_reported_PH_date"
    t.datetime "results_reported_to_clinician_date"
    t.integer  "MMWR"
    t.string   "record_number",                      :limit => 20
  end

  create_table "hospitals_participations", :force => true do |t|
    t.integer  "participation_id"
    t.string   "hospital_record_number", :limit => 100
    t.date     "admission_date"
    t.date     "discharge_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lab_results", :force => true do |t|
    t.integer  "event_id"
    t.integer  "specimen_source_id"
    t.date     "collection_date"
    t.date     "lab_test_date"
    t.integer  "tested_at_uphl_yn_id"
    t.string   "lab_result_text",      :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "laboratories", :force => true do |t|
    t.integer  "entity_id"
    t.string   "laboratory_name", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string "location_url_number", :limit => 200
  end

  create_table "materials", :force => true do |t|
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "observations", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "organization_type_id"
    t.integer  "organization_status_id"
    t.string   "organization_name",      :limit => 50
    t.datetime "duration_start_date"
    t.datetime "duration_end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations", :force => true do |t|
    t.integer  "primary_entity_id"
    t.integer  "secondary_entity_id"
    t.integer  "role_id"
    t.integer  "participation_status_id"
    t.string   "comment",                 :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
  end

  create_table "participations_treatments", :force => true do |t|
    t.integer  "participation_id"
    t.integer  "treatment_id"
    t.integer  "treatment_given_yn_id"
    t.date     "treatment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "birth_gender_id"
    t.integer  "current_gender_id"
    t.integer  "ethnicity_id"
    t.integer  "primary_language_id"
    t.string   "first_name",                  :limit => 25
    t.string   "middle_name",                 :limit => 25
    t.string   "last_name",                   :limit => 25
    t.date     "birth_date"
    t.date     "date_of_death"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "food_handler_id"
    t.integer  "healthcare_worker_id"
    t.integer  "group_living_id"
    t.integer  "day_care_association_id"
    t.integer  "age_type_id"
    t.string   "risk_factors",                :limit => 25
    t.string   "risk_factors_notes",          :limit => 100
    t.integer  "approximate_age_no_birthday"
    t.string   "first_name_soundex"
    t.string   "last_name_soundex"
  end

  create_table "people_races", :id => false, :force => true do |t|
    t.integer  "race_id"
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_type_id"
  end

  create_table "referrals", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "telephones", :force => true do |t|
    t.integer  "location_id"
    t.string   "country_code", :limit => 3
    t.string   "area_code",    :limit => 3
    t.string   "phone_number", :limit => 7
    t.string   "extension",    :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "treatments", :force => true do |t|
    t.integer "treatment_type_id"
    t.string  "treatment_name",    :limit => 100
  end

end

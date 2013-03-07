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

ActiveRecord::Schema.define(:version => 156) do
  extend MigrationHelpers

  create_table "addresses", :force => true do |t|
    t.integer  "location_id"
    t.integer  "county_id"
    t.integer  "state_id"
    t.string   "street_number", :limit => 10
    t.string   "street_name",   :limit => 50
    t.string   "unit_number",   :limit => 60
    t.string   "postal_code",   :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
  end

  add_index "addresses", ["county_id"], :name => "index_addresses_on_county_id"
  add_index "addresses", ["location_id"], :name => "index_addresses_on_location_id"
  add_index "addresses", ["state_id"], :name => "index_addresses_on_state_id"

  create_table "animals", :force => true do |t|
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "animals", ["entity_id"], :name => "index_animals_on_entity_id"

  create_table "answers", :force => true do |t|
    t.integer "event_id"
    t.integer "question_id"
    t.string  "text_answer",   :limit => 10485760
    t.integer "export_conversion_value_id"
  end

  create_table "cdc_exports", :force => true do |t|
    t.string  "type_data",          :limit => 10
    t.string  "export_column_name", :limit => 200
    t.string  "is_required",        :limit => 1
    t.integer "start_position"
    t.integer "length_to_output"
    t.string  "table_name",         :limit => 100
    t.string  "column_name",        :limit => 100
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

  add_index "clusters", ["cluster_status_id"], :name => "index_clusters_on_cluster_status_id"
  add_index "clusters", ["primary_event_id"], :name => "index_clusters_on_primary_event_id"
  add_index "clusters", ["secondary_event_id"], :name => "index_clusters_on_secondary_event_id"

  create_table "codes", :force => true do |t|
    t.string  "code_name",        :limit => 50
    t.string  "the_code",         :limit => 20
    t.string  "code_description", :limit => 100
    t.integer "sort_order"
  end

  create_table "core_fields", :force => true do |t|
    t.string   "key"
    t.string   "field_type"
    t.string   "name"
    t.boolean  "can_follow_up"
    t.string   "event_type"
    t.string   "help_text",     :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "fb_accessible"
  end

  create_table "disease_events", :force => true do |t|
    t.integer  "event_id"
    t.integer  "disease_id"
    t.integer  "hospitalized_id"
    t.integer  "died_id"
    t.date     "disease_onset_date"
    t.date     "date_diagnosed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "disease_events", ["died_id"], :name => "index_disease_events_on_died_id"
  add_index "disease_events", ["disease_id"], :name => "index_disease_events_on_disease_id"
  add_index "disease_events", ["event_id"], :name => "index_disease_events_on_event_id"
  add_index "disease_events", ["hospitalized_id"], :name => "index_disease_events_on_hospitalized_id"

  create_table "diseases", :force => true do |t|
    t.string  "disease_name",      :limit => 100
    t.text    "contact_lead_in"
    t.text    "place_lead_in"
    t.text    "treatment_lead_in"
    t.boolean "active"
    t.string  "cdc_code"
  end

  create_table "diseases_export_columns", :id => false, :force => true do |t|
    t.integer "disease_id"
    t.integer "export_column_id"
  end

  create_table "diseases_external_codes", :id => false, :force => true do |t|
    t.integer "disease_id"
    t.integer "external_code_id"
  end

  create_table "diseases_forms", :id => false, :force => true do |t|
    t.integer  "form_id"
    t.integer  "disease_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "diseases_forms", ["form_id", "disease_id"], :name => "index_diseases_forms_on_form_id_and_disease_id", :unique => true

  create_table "encounters", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "encounters", ["event_id"], :name => "index_encounters_on_event_id"

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
    t.integer  "location_type_id"
  end

  create_table "entitlements", :force => true do |t|
    t.integer  "user_id"
    t.integer  "privilege_id"
    t.integer  "jurisdiction_id"
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

  add_index "entity_groups", ["entity_group_type_id"], :name => "index_entity_groups_on_entity_group_type_id"
  add_index "entity_groups", ["primary_entity_id"], :name => "index_entity_groups_on_primary_entity_id"
  add_index "entity_groups", ["secondary_entity_id"], :name => "index_entity_groups_on_secondary_entity_id"

  create_table "event_queues", :force => true do |t|
    t.string  "queue_name",      :limit => 100
    t.integer "jurisdiction_id"
  end

  create_table "events", :force => true do |t|
    t.integer  "imported_from_id"
    t.integer  "state_case_status_id"
    t.string   "event_name",                         :limit => 100
    t.date     "event_onset_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "outbreak_associated_id"
    t.string   "outbreak_name"
    t.integer  "investigation_LHD_status_id"
    t.date     "investigation_started_date"
    t.date     "investigation_completed_LHD_date"
    t.date     "review_completed_by_state_date"
    t.date     "first_reported_PH_date"
    t.date     "results_reported_to_clinician_date"
    t.string   "record_number",                      :limit => 20
    t.integer  "MMWR_week"
    t.integer  "MMWR_year"
    t.integer  "lhd_case_status_id"
    t.string   "type"
    t.integer  "event_queue_id"
    t.string   "event_status",                       :limit => 100
    t.boolean  "sent_to_cdc"
    t.integer  "age_at_onset"
    t.integer  "age_type_id"
    t.integer  "investigator_id"
    t.boolean  "sent_to_ibis"
    t.string   "acuity"
    t.string   "other_data_1"
    t.string   "other_data_2"
    t.datetime "deleted_at"
    t.integer  "parent_id"
    t.date     "cdc_updated_at"
    t.date     "ibis_updated_at"
    t.string   "parent_guardian"
  end

  add_index "events", ["imported_from_id"], :name => "index_events_on_imported_from_id"
  add_index "events", ["investigation_LHD_status_id"], :name => "index_events_on_investigation_LHD_status_id"
  add_index "events", ["lhd_case_status_id"], :name => "index_events_on_lhd_case_status_id"
  add_index "events", ["outbreak_associated_id"], :name => "index_events_on_outbreak_associated_id"
  add_index "events", ["state_case_status_id"], :name => "index_events_on_state_case_status_id"

  create_table "export_columns", :force => true do |t|
    t.integer  "export_name_id"
    t.string   "type_data",               :limit => 10
    t.string   "export_column_name",      :limit => 20
    t.string   "table_name",              :limit => 100
    t.string   "column_name",             :limit => 100
    t.string   "is_required",             :limit => 1
    t.integer  "start_position"
    t.integer  "length_to_output"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "data_type"
    t.integer  "export_disease_group_id"
  end

  create_table "export_conversion_values", :force => true do |t|
    t.integer  "export_column_id"
    t.string   "value_from"
    t.string   "value_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
  end

  create_table "export_disease_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "export_names", :force => true do |t|
    t.string   "export_name", :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "export_predicates", :force => true do |t|
    t.string   "table_name",          :limit => 100
    t.string   "column_name",         :limit => 100
    t.string   "comparison_operator", :limit => 20
    t.string   "comparison_value",    :limit => 80
    t.string   "comparison_logical",  :limit => 5
    t.integer  "export_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_codes", :force => true do |t|
    t.string   "code_name",        :limit => 50
    t.string   "the_code",         :limit => 20
    t.string   "code_description", :limit => 100
    t.integer  "sort_order"
    t.integer  "next_ver"
    t.integer  "previous_ver"
    t.boolean  "live",                            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "jurisdiction_id"
  end

  create_table "form_elements", :force => true do |t|
    t.integer  "form_id"
    t.string   "type"
    t.string   "name"
    t.string   "description",   :limit => 10485760
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_template"
    t.integer  "template_id"
    t.boolean  "is_active",                                        :default => true
    t.integer  "tree_id"
    t.string   "condition"
    t.string   "core_path"
    t.boolean  "is_condition_code"
    t.string   "help_text",                  :limit => 2000
    t.integer  "export_column_id"
    t.integer  "export_conversion_value_id"
  end

  add_index "form_elements", ["parent_id"], :name => "fe_parent_id_index"
  add_index "form_elements", ["tree_id"], :name => "fe_tree_id_index"

  create_table "form_references", :force => true do |t|
    t.integer "event_id"
    t.integer "form_id"
  end

  create_table "forms", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "jurisdiction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_template"
    t.integer  "template_id"
    t.integer  "version"
    t.string   "status"
    t.integer  "rolled_back_from_id"
    t.string   "event_type"
  end

  create_table "hospitals_participations", :force => true do |t|
    t.integer  "participation_id"
    t.string   "hospital_record_number", :limit => 100
    t.date     "admission_date"
    t.date     "discharge_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "medical_record_number"
  end

  add_index "hospitals_participations", ["participation_id"], :name => "index_hospitals_participations_on_participation_id"

  create_table "lab_results", :force => true do |t|
    t.integer  "specimen_source_id"
    t.date     "collection_date"
    t.date     "lab_test_date"
    t.integer  "specimen_sent_to_uphl_yn_id"
    t.string   "lab_result_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participation_id"
    t.string   "test_type"
    t.string   "test_detail"
    t.integer  "interpretation_id"
    t.string   "reference_range"
  end

  add_index "lab_results", ["specimen_sent_to_uphl_yn_id"], :name => "index_lab_results_on_specimen_sent_to_uphl_yn_id"
  add_index "lab_results", ["specimen_source_id"], :name => "index_lab_results_on_specimen_source_id"

  create_table "locations", :force => true do |t|
    t.string "location_url_number", :limit => 200
  end

  create_table "materials", :force => true do |t|
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "materials", ["entity_id"], :name => "index_materials_on_entity_id"

  create_table "notes", :force => true do |t|
    t.text     "note"
    t.boolean  "struckthrough"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.string   "note_type",     :limit => 20
  end

  add_index "notes", ["event_id"], :name => "notes_event_id"

  create_table "observations", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "observations", ["event_id"], :name => "index_observations_on_event_id"

  create_table "participations", :force => true do |t|
    t.integer  "primary_entity_id"
    t.integer  "secondary_entity_id"
    t.integer  "role_id"
    t.integer  "participation_status_id"
    t.string   "comment",                   :limit => 500
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "event_id"
    t.integer  "participating_event_id"
    t.integer  "participations_place_id"
    t.integer  "participations_contact_id"
  end

  add_index "participations", ["event_id"], :name => "index_participations_on_event_id"
  add_index "participations", ["participation_status_id"], :name => "index_participations_on_participation_status_id"
  add_index "participations", ["primary_entity_id"], :name => "index_participations_on_primary_entity_id"
  add_index "participations", ["role_id"], :name => "index_participations_on_role_id"
  add_index "participations", ["secondary_entity_id"], :name => "index_participations_on_secondary_entity_id"

  create_table "participations_contacts", :force => true do |t|
    t.integer  "disposition_id"
    t.integer  "contact_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations_places", :force => true do |t|
    t.date     "date_of_exposure"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations_risk_factors", :force => true do |t|
    t.integer  "participation_id"
    t.integer  "food_handler_id"
    t.integer  "healthcare_worker_id"
    t.integer  "group_living_id"
    t.integer  "day_care_association_id"
    t.integer  "pregnant_id"
    t.date     "pregnancy_due_date"
    t.string   "risk_factors"
    t.text     "risk_factors_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "occupation"
  end

  add_index "participations_risk_factors", ["day_care_association_id"], :name => "index_participations_risk_factors_on_day_care_association_id"
  add_index "participations_risk_factors", ["food_handler_id"], :name => "index_participations_risk_factors_on_food_handler_id"
  add_index "participations_risk_factors", ["group_living_id"], :name => "index_participations_risk_factors_on_group_living_id"
  add_index "participations_risk_factors", ["healthcare_worker_id"], :name => "index_participations_risk_factors_on_healthcare_worker_id"
  add_index "participations_risk_factors", ["participation_id"], :name => "index_participations_risk_factors_on_participation_id"
  add_index "participations_risk_factors", ["pregnant_id"], :name => "index_participations_risk_factors_on_pregnant_id"

  create_table "participations_treatments", :force => true do |t|
    t.integer  "participation_id"
    t.integer  "treatment_id"
    t.integer  "treatment_given_yn_id"
    t.date     "treatment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "treatment"
  end

  add_index "participations_treatments", ["participation_id"], :name => "index_participations_treatments_on_participation_id"
  add_index "participations_treatments", ["treatment_given_yn_id"], :name => "index_participations_treatments_on_treatment_given_yn_id"
  add_index "participations_treatments", ["treatment_id"], :name => "index_participations_treatments_on_treatment_id"

# Could not dump table "people" because of following StandardError
#   Unknown type 'tsvector(2147483647)' for column 'vector'

# Since people didn't generate, I had to put it in by hand.
  create_table :people do |t|
    t.integer   :entity_id
    t.integer   :race_id
    t.integer   :birth_gender_id
    t.integer   :current_gender_id
    t.integer   :ethnicity_id
    t.integer   :primary_language_id
    t.string    :first_name, :limit => 25
    t.string    :middle_name, :limit => 25
    t.string    :last_name, :limit => 25
    t.date      :birth_date
    t.date      :date_of_death
    t.integer   :food_handler_id
    t.integer   :healthcare_worker_id
    t.integer   :group_living_id
    t.integer   :day_care_association_id
    t.integer   :age_type_id
    t.string    :risk_factors, :limit => 25
    t.string    :risk_factors_notes, :limit => 100
    t.integer   :approximate_age_no_birthday
    t.string    :first_name_soundex
    t.string    :last_name_soundex
    t.string    :person_type, :limit => 20

    t.timestamps
  end
  execute "ALTER TABLE people ADD COLUMN vector tsvector;"
  add_index (:people		, :entity_id)
  add_index (:people		, :birth_gender_id)
  add_index (:people		, :ethnicity_id)
  add_index (:people		, :primary_language_id)
  add_index (:people		, :age_type_id)
  add_index (:people		, :first_name_soundex)
  add_index (:people		, :last_name_soundex)

  create_table "people_races", :id => false, :force => true do |t|
    t.integer  "race_id"
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people_races", ["entity_id"], :name => "index_people_races_on_entity_id"
  add_index "people_races", ["race_id"], :name => "index_people_races_on_race_id"

  create_table "places", :force => true do |t|
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "place_type_id"
    t.string   "name"
    t.string   "short_name"
  end

  add_index "places", ["entity_id"], :name => "index_places_on_entity_id"
  add_index "places", ["place_type_id"], :name => "index_places_on_place_type_id"

  create_table "privileges", :force => true do |t|
    t.string "priv_name",   :limit => 50
    t.string "description", :limit => 60
  end

  create_table "privileges_roles", :force => true do |t|
    t.integer  "role_id"
    t.integer  "privilege_id"
    t.integer  "jurisdiction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.integer  "form_element_id"
    t.string   "question_text",   :limit => 10485760
    t.string   "help_text",   :limit => 10485760
    t.string   "data_type",       :limit => 50
    t.integer  "size"
    t.boolean  "is_required"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "core_data"
    t.string   "core_data_attr"
    t.string   "short_name"
    t.string   "style"
  end

  add_index "questions", ["form_element_id"], :name => "q_form_element_id_index"

  create_table "referrals", :force => true do |t|
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referrals", ["event_id"], :name => "index_referrals_on_event_id"

  create_table "reporting_agency_types", :force => true do |t|
    t.integer  "place_id"
    t.integer  "code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "role_memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "jurisdiction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "role_name",   :limit => 100
    t.string "description"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "category",    :limit => 40
    t.string   "priority",    :limit => 40
    t.integer  "event_id"
    t.integer  "user_id"
    t.date     "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["event_id"], :name => "index_tasks_on_event_id"
  add_index "tasks", ["user_id"], :name => "index_tasks_on_user_id"

  create_table "telephones", :force => true do |t|
    t.integer  "location_id"
    t.string   "country_code",  :limit => 3
    t.string   "area_code",     :limit => 3
    t.string   "phone_number",  :limit => 7
    t.string   "extension",     :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
  end

  add_index "telephones", ["location_id"], :name => "index_telephones_on_location_id"

  create_table "treatments", :force => true do |t|
    t.integer "treatment_type_id"
    t.string  "treatment_name",    :limit => 100
  end

  add_index "treatments", ["treatment_type_id"], :name => "index_treatments_on_treatment_type_id"

  create_table "users", :force => true do |t|
    t.string   "uid",                   :limit => 50
    t.string   "given_name",            :limit => 127
    t.string   "first_name",            :limit => 32
    t.string   "last_name",             :limit => 64
    t.string   "initials",              :limit => 8
    t.string   "generational_qualifer", :limit => 8
    t.string   "user_name",             :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "event_view_settings"
  end

# Add in some foreign keys
  add_foreign_key :addresses, :county_id, :external_codes
  add_foreign_key :addresses, :state_id,  :external_codes

  add_foreign_key :disease_events, :died_id, :external_codes
  add_foreign_key :disease_events, :disease_id, :diseases
  add_foreign_key :disease_events, :event_id, :events
  add_foreign_key :disease_events, :hospitalized_id, :external_codes

  add_foreign_key :diseases_export_columns, :disease_id, :diseases
  add_foreign_key :diseases_export_columns, :export_column_id, :export_columns

  add_foreign_key :encounters, :event_id, :events

  add_foreign_key :events, :age_type_id, :external_codes
  add_foreign_key :events, :imported_from_id, :external_codes
  add_foreign_key :events, :investigator_id, :users
  add_foreign_key :events, :lhd_case_status_id, :external_codes
  add_foreign_key :events, :state_case_status_id, :external_codes

  add_foreign_key :export_columns, :export_name_id, :export_names

  add_foreign_key :export_conversion_values, :export_column_id, :export_columns

  add_foreign_key :hospitals_participations, :participation_id, :participations

  add_foreign_key :lab_results, :participation_id, :participations
  add_foreign_key :lab_results, :specimen_source_id, :external_codes

  add_foreign_key :notes, :event_id, :events
  add_foreign_key :notes, :user_id,  :users

  add_foreign_key :participations, :participation_status_id, :codes
  add_foreign_key :participations, :primary_entity_id,   :entities
  add_foreign_key :participations, :secondary_entity_id, :entities
  add_foreign_key :participations, :event_id, :events

  add_foreign_key :participations_risk_factors, :day_care_association_id, :external_codes
  add_foreign_key :participations_risk_factors, :food_handler_id, :external_codes
  add_foreign_key :participations_risk_factors, :group_living_id, :external_codes
  add_foreign_key :participations_risk_factors, :healthcare_worker_id, :external_codes
  add_foreign_key :participations_risk_factors, :participation_id, :participations
  add_foreign_key :participations_risk_factors, :pregnant_id, :external_codes

  add_foreign_key :participations_treatments, :participation_id, :participations
  add_foreign_key :participations_treatments, :treatment_given_yn_id, :external_codes
  add_foreign_key :participations_treatments, :treatment_id, :treatments

  add_foreign_key :people, :birth_gender_id, :external_codes
  add_foreign_key :people, :ethnicity_id, :external_codes
  add_foreign_key :people, :primary_language_id, :external_codes
  add_foreign_key :people, :entity_id, :entities

  add_foreign_key :places, :entity_id, :entities

  add_foreign_key :privileges_roles, :jurisdiction_id, :entities
  add_foreign_key :privileges_roles, :privilege_id, :privileges
  add_foreign_key :privileges_roles, :role_id, :roles

  add_foreign_key :role_memberships, :jurisdiction_id, :entities
  add_foreign_key :role_memberships, :role_id, :roles
  add_foreign_key :role_memberships, :user_id, :users

  add_foreign_key :tasks, :event_id, :events
  add_foreign_key :tasks, :user_id, :users

  add_foreign_key :treatments, :treatment_type_id, :codes


# Not everything can be done in ruby. Here's some of the ugliness.
  begin
    execute "CREATE LANGUAGE plpgsql;"
  rescue
    # No-op, language probably already exists. If not, the next execution will fail.
  end

  # can't forget these
  execute 'CREATE SEQUENCE events_record_number_seq START WITH 2011000001 INCREMENT BY 1 MAXVALUE 2011999999 MINVALUE 2011000001 CACHE 1'
  execute "create sequence tree_id_generator"

  # full text search stuff
  execute "CREATE INDEX people_fts_vector_index ON people USING gist(vector);"

  execute "CREATE FUNCTION people_trigger() RETURNS trigger AS $$
                      begin
                        new.vector :=
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.first_name,'')), 'B') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.last_name,'')), 'B') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.first_name_soundex,'')), 'A') ||
                          setweight(to_tsvector('pg_catalog.english', coalesce(new.last_name_soundex,'')), 'A');
                        return new;
                      end
                    $$ LANGUAGE plpgsql;"

  execute "CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON people
                    FOR EACH ROW EXECUTE PROCEDURE people_trigger();"
end

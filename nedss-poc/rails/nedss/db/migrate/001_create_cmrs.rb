class CreateCmrs < ActiveRecord::Migration
  def self.up
    create_table "cmrs", :force => true do |t|
      t.string    "accession_number",       :limit => 100, :default => "",  :null => false
      t.string    "entered_by",             :limit => 10,  :default => "",  :null => false
      t.string    "last_name",              :limit => 40,  :default => "",  :null => false
      t.string    "first_name",             :limit => 40,  :default => "",  :null => false
      t.date      "date_of_birth"
      t.integer   "age",                    :limit => 4
      t.string    "street_address",         :limit => 100
      t.string    "city",                   :limit => 40
      t.string    "state",                  :limit => 2
      t.string    "zip_code",               :limit => 5
      t.string    "county",                 :limit => 40
      t.string    "country",                :limit => 40
      t.string    "phone_number",           :limit => 20
      t.string    "gender",                 :limit => 1
      t.string    "race",                   :limit => 20
      t.string    "ethnicity",              :limit => 20
      t.date      "onset_date"
      t.string    "clinician_name",         :limit => 40
      t.string    "clinician_phone_number", :limit => 20
      t.string    "patient_hospitalized",   :limit => 1
      t.string    "hospitals",              :limit => 100
      t.string    "did_patient_die",        :limit => 1
      t.date      "expired_date"
      t.string    "disease",                :limit => 40
      t.string    "reported_by",            :limit => 40
      t.date      "reported_date"
      t.string    "lhd_investigator",       :limit => 40
      t.string    "reporting_phone_number", :limit => 20
      t.string    "lhd_reviewed_by",        :limit => 40
      t.date      "lhd_reviewed_date"
      t.string    "case_classification",    :limit => 20
      t.timestamp "created_at"
      t.timestamp "updated_at"
    end
  end

  def self.down
    drop_table :cmrs
  end
end

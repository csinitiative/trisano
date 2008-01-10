class CreatePatients < ActiveRecord::Migration
  def self.up
    create_table :patients do |t|
      t.string   :last_name,                    :limit => 25, :null => false
      t.string   :first_name, :middle_name,     :limit => 25
      t.date     :date_of_birth
      t.string   :street_address,               :limit => 55
      t.string   :city, :county, :country,      :limit => 40
      t.string   :state,                        :limit => 2
      t.string   :zip_code,                     :limit => 10
      t.string   :phone_1, :phone_2, :phone_3,  :limit => 20
      t.string   :sex,                          :limit => 1
      t.integer  :race_id, :ethnicity_id, :language_id
      t.string   :primary_language_if_other,    :limit => 20
      t.timestamps
    end
  end

  def self.down
    drop_table :patients
  end
end

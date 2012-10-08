class AddRepeaterToCoreField < ActiveRecord::Migration
  def self.up
    CoreField.transaction do
      add_column :core_fields, :repeater, :boolean, :default => false
      CoreField.reset_column_information
      core_fields = %w(
        morbidity_event[hospitalization_facilities][hospitals_participation][admission_date]
      )
      core_fields.each do |core_field|
          CoreField.find_by_key(core_field).update_attribute(:repeater, true) 
      end
    end
  end

  def self.down
    remove_column :core_field, :repeater
  end
end

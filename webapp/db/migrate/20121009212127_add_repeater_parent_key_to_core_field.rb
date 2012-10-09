class AddRepeaterParentKeyToCoreField < ActiveRecord::Migration
  def self.up
    CoreField.transaction do
      add_column :core_fields, :repeater_parent_key, :string
      CoreField.reset_column_information
      core_fields = {
        "morbidity_event[hospitalization_facilities][hospitals_participation][admission_date]" =>
	"morbidity_event[hospitalization_facilities]"
      }
      core_fields.each do |key, repeater_parent_key|
          CoreField.find_by_key(key).update_attribute(:repeater_parent_key, repeater_parent_key) 
      end
    end
  end

  def self.down
    remove_column :core_field, :repeater_parent_key
  end
end

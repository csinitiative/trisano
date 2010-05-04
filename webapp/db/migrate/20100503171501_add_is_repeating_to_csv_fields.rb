class AddIsRepeatingToCsvFields < ActiveRecord::Migration
  def self.up
    add_column :csv_fields, :collection, :string

    [["contact_event", "contact_hospital_admission_date"],
      ["contact_event", "contact_hospital_discharge_date"],
      ["contact_event", "contact_hospitalization_facility"],
      ["contact_event", "contact_hospital_medical_record_no"],
      ["morbidity_event", "patient_hospital_admission_date"],
      ["morbidity_event", "patient_hospital_discharge_date"],
      ["morbidity_event", "patient_hospital_medical_record_no"]].each do |csv_field|

      field = CsvField.find_by_event_type_and_long_name(csv_field[0], csv_field[1])

      unless field.nil?
        first_position = field.use_description.index(".first")
        try_position = field.use_description.index(".try")

        collection_name = field.use_description[0..first_position-1]
        new_use_description = field.use_description[try_position+1...field.use_description.size]

        unless field.use_code.blank?
          new_use_code = field.use_code[try_position+1...field.use_code.size]
          field.use_code = new_use_code
        end

        field.use_description = new_use_description
        field.collection = collection_name
        field.save!
      end
    end
  end

  def self.down
    remove_column :csv_fields, :collection
  end
end

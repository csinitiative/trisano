class AddScaleFieldToLoincCodes < ActiveRecord::Migration
  def self.up
    add_column    :loinc_codes, :scale_id, :integer
  end

  def self.down
    remove_column :loinc_codes, :scale_id
  end
end

class AddLoincCodesOrganisms < ActiveRecord::Migration
  def self.up
    add_column :loinc_codes, :organism_id, :integer
  end

  def self.down
    remove_column :loinc_codes, :organism_id
  end
end

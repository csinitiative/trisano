class AddLoincCodesOrganisms < ActiveRecord::Migration
  def self.up
    create_table :loinc_codes_organisms do |t|
      t.column :loinc_code_id, :integer
      t.column :organism_id,   :integer

      t.timestamps
    end
  end

  def self.down
    drop_table :loinc_codes_organisms
  end
end

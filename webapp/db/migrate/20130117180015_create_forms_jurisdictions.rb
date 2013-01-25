class CreateFormsJurisdictions < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    create_table :forms_jurisdictions, :id => false do |t|
      t.integer :form_id, :null => false
      t.integer :jurisdiction_id, :null => false
    end

    Form.all.each do |f|
      next if f.jurisdiction_id.nil?
      f.jurisdictions << PlaceEntity.find(f.jurisdiction_id)
    end
  end

  def self.down
    drop_table :forms_jurisdictions
  end
end

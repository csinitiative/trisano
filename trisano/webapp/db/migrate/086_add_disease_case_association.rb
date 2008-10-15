class AddDiseaseCaseAssociation < ActiveRecord::Migration
  def self.up
    create_table :diseases_external_codes, :id => false do |t|
      t.integer :disease_id
      t.integer :external_code_id
    end
  end

  def self.down
    drop_table :diseases_external_codes
  end
end

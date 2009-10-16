class CommonTestTypesDiseases < ActiveRecord::Migration
  def self.up
    create_table :common_test_types_diseases do |t|
      t.integer :disease_id,          :null => false
      t.integer :common_test_type_id, :null => false
      t.timestamps
    end
    add_index :common_test_types_diseases, [:disease_id, :common_test_type_id], :unique => true, :name => :by_common_test_type_and_disease
  end

  def self.down
    remove_index :common_test_types_diseases, :name => :by_common_test_type_and_disease
    drop_table :common_test_types_diseases
  end
end

class AddTestTypeAndInterpretationToLabs < ActiveRecord::Migration
  def self.up
    add_column :lab_results, :test_type, :string
    add_column :lab_results, :interpretation, :string
  end

  def self.down
    remove_column :lab_results, :test_type
    remove_column :lab_results, :interpretation
  end
end

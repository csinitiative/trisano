class UpdateLabsDestructive < ActiveRecord::Migration
  def self.up
    remove_column :lab_results, :test_type
    remove_column :lab_results, :test_detail
    remove_column :lab_results, :lab_result_text
    remove_column :lab_results, :interpretation_id
  end

  def self.down
    add_column :lab_results, :test_type, :string
    add_column :lab_results, :test_detail, :string
    add_column :lab_results, :lab_result_text, :string
    add_column :lab_results, :interpretation_id, :integer
  end
end

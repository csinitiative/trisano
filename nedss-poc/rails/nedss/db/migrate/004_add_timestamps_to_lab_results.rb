class AddTimestampsToLabResults < ActiveRecord::Migration
  def self.up
    add_column :lab_results, :created_at, :datetime
    add_column :lab_results, :updated_at, :datetime
  end

  def self.down
    remove_column :lab_results, :created_at
    remove_column :lab_results, :updated_at
  end
end

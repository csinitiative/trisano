class ChangeDatetimesToDatesInLabResults < ActiveRecord::Migration
  def self.up
    change_column :lab_results, :collection_date, :date
    change_column :lab_results, :lab_test_date, :date
  end

  def self.down
    change_column :lab_results, :collection_date, :datetime
    change_column :lab_results, :lab_test_date, :datetime
  end
end

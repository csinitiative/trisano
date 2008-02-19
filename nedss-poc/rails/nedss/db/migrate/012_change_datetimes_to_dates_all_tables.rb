class ChangeDatetimesToDatesAllTables < ActiveRecord::Migration
  def self.up
    change_column :events, :investigation_started_date, :date
    change_column :events, :investigation_completed_LHD_date, :date
    change_column :events, :review_completed_UDOH_date, :date
    change_column :events, :first_reported_PH_date, :date
    change_column :events, :results_reported_to_clinician_date, :date

    change_column :organizations, :duration_start_date, :date
    change_column :organizations, :duration_end_date, :date
  end

  def self.down
    change_column :events, :investigation_started_date, :datetime
    change_column :events, :investigation_completed_LHD_date, :datetime
    change_column :events, :review_completed_UDOH_date, :datetime
    change_column :events, :first_reported_PH_date, :datetime
    change_column :events, :first_reported_to_clinician_date, :datetime

    change_column :organizations, :duration_start_date, :datetime
    change_column :organizations, :duration_end_date, :datetime
  end
end

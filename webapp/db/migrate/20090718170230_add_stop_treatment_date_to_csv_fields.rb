class AddStopTreatmentDateToCsvFields < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      execute("INSERT INTO csv_fields (long_name, sort_order, use_description, export_group, created_at, updated_at)  
               VALUES ('stop_treatment_date', 40, 'stop_treatment_date', 'treatment', '#{Time.now}', '#{Time.now}')")
    end
  end

  def self.down
  end
end

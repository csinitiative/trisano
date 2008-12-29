class CreateReportingAgencyTypes < ActiveRecord::Migration
  def self.up
    create_table :reporting_agency_types do |t|
      t.integer :place_id
      t.integer :code_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reporting_agency_types
  end
end

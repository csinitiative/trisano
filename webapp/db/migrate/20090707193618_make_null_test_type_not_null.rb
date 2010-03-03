class MakeNullTestTypeNotNull < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      LabResult.update_all("test_type = 'N/A'", "test_type IS NULL OR test_type = ''")
    end
  end

  def self.down
  end
end

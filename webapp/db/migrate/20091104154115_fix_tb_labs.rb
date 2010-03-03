class FixTbLabs < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/fix_tb_labs.rb"

      execute("DELETE FROM csv_fields WHERE long_name = 'lab_result'")

      execute("UPDATE csv_fields
               SET use_description = 'specimen_sent_to_state.try(:code_description)'
               WHERE long_name = 'lab_specimen_sent_to_state'")
    end
  end

  def self.down
  end
end

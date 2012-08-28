class AddRepeaterCoreFields < ActiveRecord::Migration
  def self.up
puts "Loading core fields from db/defaults/core_fields.yml"
core_fields = YAML::load_file("#{RAILS_ROOT}/db/defaults/core_fields.yml")
CoreField.load!(core_fields)
  end

  def self.down
  end
end

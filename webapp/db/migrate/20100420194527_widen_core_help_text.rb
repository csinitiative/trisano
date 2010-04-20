class WidenCoreHelpText < ActiveRecord::Migration
  def self.up
    change_column(:core_fields, :help_text, :text)
  end

  def self.down
    # not going to bother rolling this back
  end
end

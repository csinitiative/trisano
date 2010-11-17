
class AddRequiredForSectionToCoreFields < ActiveRecord::Migration
  def self.up
    # using SQL because AR=JDBC can't seem to get this right
    transaction do
      execute "ALTER TABLE core_fields ADD COLUMN required_for_section boolean;"
      execute "ALTER TABLE core_fields ALTER COLUMN required_for_section SET DEFAULT false;"
      execute "UPDATE core_fields SET required_for_section = false;"
      execute "ALTER TABLE core_fields ALTER COLUMN required_for_section SET NOT NULL;"
    end
  end

  def self.down
    remove_column :core_fields, :required_for_section
  end
end

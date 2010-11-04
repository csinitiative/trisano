class AddRequiredFieldsToCoreFields < ActiveRecord::Migration
  def self.up
    # using SQL because AR=JDBC can't seem to get this right
    transaction do
      execute "ALTER TABLE core_fields ADD COLUMN required_for_event boolean;"
      execute "ALTER TABLE core_fields ALTER COLUMN required_for_event SET DEFAULT false;"
      execute "UPDATE core_fields SET required_for_event = false;"
      execute "ALTER TABLE core_fields ALTER COLUMN required_for_event SET NOT NULL;"
    end
  end

  def self.down
    remove_column :core_fields, :required_for_event
  end
end

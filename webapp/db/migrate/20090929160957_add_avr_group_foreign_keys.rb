class AddAvrGroupForeignKeys < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_foreign_key :avr_groups_diseases, :avr_group_id, :avr_groups
    add_foreign_key :avr_groups_diseases, :disease_id, :diseases

    change_column :avr_groups, :name, :string, :null => false
    execute("ALTER TABLE avr_groups ADD CONSTRAINT avr_groups_unique_name UNIQUE (name);")
  end

  def self.down
    remove_foreign_key :avr_groups_diseases, :avr_group_id
    remove_foreign_key :avr_groups_diseases, :disease_id

    change_column :avr_groups, :name, :string, :null => true
    execute("ALTER TABLE avr_groups DROP CONSTRAINT avr_groups_unique_name;")
  end
end

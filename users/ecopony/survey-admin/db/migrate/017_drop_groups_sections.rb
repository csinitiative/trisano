class DropGroupsSections < ActiveRecord::Migration
  def self.up
    drop_table :groups_sections
  end

  def self.down
    create_table :groups_sections do |t|
      t.integer :form_id
      t.integer :group_id
      t.integer :section_id
      t.integer :position

      t.timestamps
    end
  end
end

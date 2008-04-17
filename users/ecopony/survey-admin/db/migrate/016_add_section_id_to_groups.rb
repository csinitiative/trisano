class AddSectionIdToGroups < ActiveRecord::Migration

  def self.up
    add_column :groups, :section_id, :integer
  end

  def self.down
    remove_column :groups, :section_id
  end
end

class AddEntityPrivileges < ActiveRecord::Migration
  def self.up
    Privilege.find_or_create_by_priv_name('manage_entities').save!
  end

  def self.down
  end
end

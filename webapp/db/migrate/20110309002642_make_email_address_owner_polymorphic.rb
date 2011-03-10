class MakeEmailAddressOwnerPolymorphic < ActiveRecord::Migration
  def self.up
    rename_column :email_addresses, :entity_id, :owner_id
    add_column :email_addresses, :owner_type, :string, :null => false
    EmailAddress.all.each do |email_address|
      email_address.update_attribute :owner_type, 'Entity'
    end
  end

  def self.down
    remove_column :email_addresses, :owner_type
    rename_column :email_addresses, :owner_id, :entity_id
  end
end

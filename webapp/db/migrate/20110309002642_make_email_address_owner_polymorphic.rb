class MakeEmailAddressOwnerPolymorphic < ActiveRecord::Migration
  def self.up
    transaction do
      rename_column :email_addresses, :entity_id, :owner_id
      add_column :email_addresses, :owner_type, :string
      EmailAddress.all.each do |email_address|
        email_address.update_attribute :owner_type, 'Entity'
      end
    end
  end

  def self.down
    transaction do
      remove_column :email_addresses, :owner_type
      rename_column :email_addresses, :owner_id, :entity_id
    end
  end
end

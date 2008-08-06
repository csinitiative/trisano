class AddEmailAddressField < ActiveRecord::Migration

  def self.up
    add_column :telephones, :email_address, :string
  end

  def self.down
    remove_column :telephones, :email_address
  end
end

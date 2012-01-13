class EmailAddressesNonUnique < ActiveRecord::Migration
  def self.up
    execute %{
        DROP INDEX index_email_addresses_on_email_address;
        CREATE INDEX index_email_addresses_on_email_address ON email_addresses (email_address);
    }
  end

  def self.down
    execute %{
        DROP INDEX index_email_addresses_on_email_address;
        CREATE UNIQUE INDEX index_email_addresses_on_email_address ON email_addresses (email_address);
    }
  end
end

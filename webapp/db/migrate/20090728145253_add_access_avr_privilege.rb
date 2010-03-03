class AddAccessAvrPrivilege < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == "production"
      execute "INSERT INTO privileges (priv_name) VALUES ('access_avr')"
    end
  end

  def self.down
  end
end

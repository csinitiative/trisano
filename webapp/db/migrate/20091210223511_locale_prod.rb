class LocaleProd < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      Privilege.transaction do
        admin = Role.find_or_create_by_role_name(:role_name => "Administrator")
        priv  = Privilege.find_or_create_by_priv_name('manage_locales')
        unless admin.privileges.any? { |p| p.priv_name.to_s == 'manage_locales' }
          admin.privileges << priv
          admin.save!
        end
      end
    end
  end

  def self.down
  end
end

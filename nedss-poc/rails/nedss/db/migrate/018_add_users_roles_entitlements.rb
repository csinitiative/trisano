class AddUsersRolesEntitlements < ActiveRecord::Migration
  def self.up
#
# This migration adds the basic user, role, and entitlement capabilities to the
# UT-NEDSS database for the CMR in Release 1 Iteration 4. 
# Evan Bauer 14-Mar-2008
#
    create_table  :users do |t|
      t.integer	  :uid
      t.string    :given_name, :limit => 127
      t.string    :first_name, :limit => 32
      t.string    :last_name,  :limit => 64
      t.string    :initials,   :limit => 8
      t.string	  :generational_qualifer, :limit => 8
      t.string    :user_name,   :limit => 20
      t.string    :uid,         :limit => 9
      t.timestamps
    end

# Initial privs should include view, update, and administer
    create_table  :privileges do |t|
      t.string    :priv_name, :limit => 15
      t.string    :description, :limit => 60
    end

    create_table  :entitlements do |t|
      t.integer   :user_id
      t.integer   :privilege_id
      t.integer   :jurisdiction_id
      t.timestamps
    end

    execute "ALTER TABLE entitlements
                ADD CONSTRAINT  fk_UserId 
                FOREIGN KEY (user_id) 
                REFERENCES users(id)"
        
    execute "ALTER TABLE entitlements
                ADD CONSTRAINT  fk_PrivilegeId 
                FOREIGN KEY (privilege_id) 
                REFERENCES privileges(id)"

# How do we make certain that this entity is a jurisdiction?
    execute "ALTER TABLE entitlements
                ADD CONSTRAINT  fk_JurisdictionId
                FOREIGN KEY (jurisdiction_id) 
                REFERENCES entities(id)"

# Initial roles should include Administrator and Investigator
# Note that there is a role_id column in participations, but no role table,
# we may want to adjust nomenclature
    create_table  :roles do |t|
      t.string    :role_name, :limit => 15
      t.string    :description, :limit => 60
    end

    create_table  :users_roles do |t|
      t.integer   :user_id
      t.integer   :role_id
      t.integer   :jurisdiction_id
      t.timestamps
    end
      
    execute "ALTER TABLE users_roles
                ADD CONSTRAINT  fk_UserId 
                FOREIGN KEY (user_id) 
                REFERENCES users(id)"
        
    execute "ALTER TABLE users_roles
                ADD CONSTRAINT  fk_RoleId 
                FOREIGN KEY (role_id) 
                REFERENCES roles(id)"

# How do we make certain that this entity is a jurisdiction?
    execute "ALTER TABLE users_roles
                ADD CONSTRAINT  fk_JurisdictionId
                FOREIGN KEY (jurisdiction_id) 
                REFERENCES entities(id)"

#

    create_table  :roles_entitlements do |t|
      t.integer   :role_id
      t.integer   :entitlement_id
      t.integer   :jurisdiction_id
      t.timestamps
    end

    execute "ALTER TABLE roles_entitlements
                ADD CONSTRAINT  fk_RoleId 
                FOREIGN KEY (role_id) 
                REFERENCES roles(id)"
        
    execute "ALTER TABLE roles_entitlements
                ADD CONSTRAINT  fk_EntitlementId 
                FOREIGN KEY (entitlement_id) 
                REFERENCES entitlements(id)"

# How do we make certain that this entity is a jurisdiction?
    execute "ALTER TABLE roles_entitlements
                ADD CONSTRAINT  fk_JurisdictionId
                FOREIGN KEY (jurisdiction_id) 
                REFERENCES entities(id)"

   
  end	

  def self.down
    drop_table :users
    drop_table :privileges
    drop_table :entitlements
    drop_table :roles
    drop_table :users_roles
    drop_table :roles_entitlements
  end
end

class User < ActiveRecord::Base
  
  has_many :role_memberships, :include => [:role]
  has_many :roles, :through => :role_memberships, :uniq => true
  
  has_many :entitlements, :include => [:privilege]
  has_many :privileges, :through => :entitlements
  
  validates_presence_of :uid, :user_name
  
  # Checks to see if  a user has a role in any jurisdiction at all
  # This gets them into tools, for one thing.
  
  def is_admin?
    roles.each do |role|
      return true if role.role_name == "administrator"
    end
    false
  end
  
  def is_state_user?
    roles.each do |role|
      return true if role.role_name == "state user"
    end
    false
  end
  
  def is_investigator?
    roles.each do |role|
      return true if role.role_name == "investigator"
    end
    false
  end
  
  # Get specific by jurisdiction
  
  def has_role_in?(jurisdiction)
    role_memberships.each do |rm|
      return true if rm.jurisdiction.id == jurisdiction.id
    end
    false 
  end
  
  def has_entitlement_in?(jurisdiction)
    entitlements.each do |ent|
      return true if ent.jurisdiction.id == jurisdiction.id
    end
    false 
  end

  # Manage role memberships
   
  def add_role_membership(role, jurisdiction)
    role_memberships << RoleMembership.new(:role => role, :jurisdiction => jurisdiction)
  end
  
  def remove_role_membership(role, jurisdiction)
    # Debt? Is there some way to get the 
    role_memberships.each do |rm|
      if rm.role_id == role.id && rm.jurisdiction_id ==  jurisdiction.id
        rm.destroy
        role_memberships.reload
        return true
      end
    end
    false
  end
  
  # Manage entitlements
  
  def add_entitlement(privilege, jurisdiction)
    entitlements << Entitlement.new(:privilege => privilege, :jurisdiction => jurisdiction)
  end
  
  def remove_entitlement(privilege, jurisdiction)
    entitlements.each do |ent|
      if ent.privilege_id == privilege.id && ent.jurisdiction_id ==  jurisdiction.id
        ent.destroy 
        entitlements.reload
        return true
      end
    end
    false
  end
  
  # Convenience methods to find/set the current user on the thread from anywhere in the app
  
  def self.current_user=(user)
    Thread.current[:user] = user
  end

  def self.current_user
    Thread.current[:user]
  end

end

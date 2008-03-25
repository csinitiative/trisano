class User < ActiveRecord::Base
  
  has_many :role_memberships, :include => [:role, :jurisdiction]
  has_many :roles, :through => :role_memberships, :uniq => true
  has_many :jurisdictions, :through => :role_memberships
  
  has_many :entitlements, :include => [:privilege]
  has_many :privileges, :through => :entitlements
  
  validates_associated :role_memberships
  validates_presence_of :uid, :user_name
  
  after_update :save_role_memberships
  after_validation :clear_base_error
  
  # Checks to see if  a user has a role in any jurisdiction at all
  # This gets them into tools, for one thing.
  
  def is_admin?
    roles.detect { |role| role.role_name == "administrator" }.nil? ? false : true
  end
  
  def is_investigator?
    roles.detect { |role| role.role_name == "investigator" }.nil? ? false : true
  end
  
  # Get specific by jurisdiction
  
  def has_role_in?(jurisdiction)
    role_memberships.detect { |rm| rm.jurisdiction.id ==  jurisdiction.id }.nil? ? false : true
  end
  
  def has_entitlement_in?(jurisdiction)
    entitlements.detect { |ent| ent.jurisdiction.id == jurisdiction.id }.nil? ? false : true
  end

  # Manage role memberships
   
  def add_role_membership(role, jurisdiction)
    role_memberships << RoleMembership.new(:role => role, :jurisdiction => jurisdiction)
  end
  
  def remove_role_membership(role, jurisdiction)
    # Debt? What's the preferred way to manipulate join models and have changes reflected in memory?
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
  
  def role_membership_attributes=(rm_attributes)
    rm_attributes.each do |attributes|
      if attributes[:id].blank?
        role_memberships.build(attributes)
      else
        rm = role_memberships.detect { |rm| rm.id == attributes[:id].to_i }
        rm.attributes = attributes
      end
    end
  end
  
  def save_role_memberships
    role_memberships.each do |rm|
      if rm.should_destroy?
        rm.destroy
      else
        rm.save(false)
      end
    end
  end
  
  # Convenience methods to find/set the current user on the thread from anywhere in the app
  
  def self.current_user=(user)
    Thread.current[:user] = user
  end

  def self.current_user
    Thread.current[:user]
  end
  
  def clear_base_error
    errors.delete(:role_memberships)
  end

end

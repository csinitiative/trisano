class User < ActiveRecord::Base
  
  has_many :role_memberships, :include => [:role, :jurisdiction]
  has_many :roles, :through => :role_memberships, :uniq => true
  has_many :jurisdictions, :through => :role_memberships
  
  has_many :entitlements, :include => [:privilege]
  has_many :privileges, :through => :entitlements
  
  validates_associated :role_memberships
  validates_presence_of :uid, :user_name
  validates_length_of :uid, :maximum => 9
  
  after_update :save_role_memberships
  after_validation :clear_base_error
  
  def is_admin?
    roles.detect { |role| role.role_name == "administrator" }.nil? ? false : true
  end
  
  def is_investigator?
    roles.detect { |role| role.role_name == "investigator" }.nil? ? false : true
  end
  
  def has_role_in?(jurisdiction)
    role_memberships.detect { |rm| rm.jurisdiction.id ==  jurisdiction.id }.nil? ? false : true
  end
  
  def has_entitlement_in?(jurisdiction)
    entitlements.detect { |ent| ent.jurisdiction.id == jurisdiction.id }.nil? ? false : true
  end
  
  def is_entitled_to_in?(privilege, jurisdiction)
    entitlements.detect { |ent| ent.privilege_id == privilege.id && ent.jurisdiction_id == jurisdiction.id }.nil? ? false : true
  end
  
  def role_membership_attributes=(rm_attributes)
    seen_before = []
    rm_attributes.each do |attributes|
      if attributes[:id].blank?
        attribute_check = seen_before.detect { |at| at[:role_id] == attributes[:role_id] and at[:jurisdiction_id] == attributes[:jurisdiction_id] } 
        if attribute_check.nil?
          role_memberships.build(attributes)
          seen_before << attributes
        end
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

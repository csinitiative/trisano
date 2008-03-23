class Role < ActiveRecord::Base
  
  has_many :role_memberships
  has_many :users, :through => :role_memberships
  
  has_many :privileges_roles
  has_many :privileges, :through => :privileges_roles    
  
end

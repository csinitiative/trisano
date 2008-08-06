class Privilege < ActiveRecord::Base
  
  has_many :entitlements
  has_many :users, :through => :entitlements
  
  has_many :privileges_roles
  has_many :roles, :through => :privileges_roles
  
end

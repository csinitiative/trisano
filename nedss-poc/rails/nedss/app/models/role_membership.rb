class RoleMembership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :role
  
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  
  # validates_uniqueness_of :user_id, :scope => :role_id # Not enough, can you constrain uniqueness by both role and jurisdiction?
  
end
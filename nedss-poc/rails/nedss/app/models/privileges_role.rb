class PrivilegesRole < ActiveRecord::Base
  
  belongs_to :role
  belongs_to :privilege
  
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  
end

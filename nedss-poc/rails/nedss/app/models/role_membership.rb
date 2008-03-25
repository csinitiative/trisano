class RoleMembership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :role
  
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  # validates_presence_of :user_id, :role_id, :jurisdiction_id
  #  
#    def validate
#      if new_record?
#        existing_membership = RoleMembership.find_by_user_id_and_role_id_and_jurisdiction_id(self.user.id, self.role.id, self.jurisdiction.id)
#        errors.add_to_base("dupe") unless existing_membership.nil?
#      end
#    end
  
  # validates_uniqueness_of :user_id, :scope => :role_id # Not enough, can you constrain uniqueness by both role and jurisdiction?
  
end
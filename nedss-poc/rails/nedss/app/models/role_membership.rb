class RoleMembership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :role
  
  belongs_to :jurisdiction, :class_name => 'Entity', :foreign_key => :jurisdiction_id
  
   validates_uniqueness_of :user_id, :scope => [:role_id, :jurisdiction_id],
     :message => "duplicate role membership is not permitted", :on => :create
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
end
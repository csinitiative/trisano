class GroupsSection < ActiveRecord::Base
  belongs_to :group
  belongs_to :section
  belongs_to :form
  
  # acts_as_list :scope => [:group, :section]
  
end

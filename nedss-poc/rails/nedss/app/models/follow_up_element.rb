class FollowUpElement < FormElement
  
  attr_accessor :parent_element_id
  
  validates_presence_of :condition
    
end

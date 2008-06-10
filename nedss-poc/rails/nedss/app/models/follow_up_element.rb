class FollowUpElement < FormElement
  
  attr_accessor :parent_element_id, :core_data
  
  validates_presence_of :condition
    
end

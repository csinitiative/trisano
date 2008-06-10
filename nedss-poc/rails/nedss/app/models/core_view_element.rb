class CoreViewElement < FormElement
  
  attr_accessor :parent_element_id
  
  validates_presence_of :name
  
end

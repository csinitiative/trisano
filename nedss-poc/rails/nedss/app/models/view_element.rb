class ViewElement < FormElement

  validates_presence_of :name
  
  attr_accessor :parent_element_id
  
end

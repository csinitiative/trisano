class ValueSetElement < FormElement
  
  attr_accessor :parent_element_id
  
  after_create :add_values_to_hierarchy
  
  def value_elements
    unless self.id.blank?
      return self.children
    else
      return []
    end
    
  end
  
  def save_and_add_to_form(parent_element_id)
    if self.valid?
      self.save
      parent_element = FormElement.find(parent_element_id)
      parent_element.add_child(self)
    end
  end
  
  def value_attributes=(value_attributes)
    @transient_value_elements = []
    value_attributes.each do |attributes|
      value = ValueElement.create(attributes)
      @transient_value_elements << value
    end
  end
  
  private
  
  def add_values_to_hierarchy
    unless @transient_value_elements.nil?
      @transient_value_elements.each do |a|
        self.add_child a
      end
    end
  end
  
end

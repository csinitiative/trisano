class CoreFieldElement < FormElement
  
  attr_accessor :parent_element_id
  validates_presence_of :core_path
  validates_presence_of :name
  
  def save_and_add_to_form
    self.name = Event.exposed_attributes[self.core_path][:name]
    super
  end
  
  def available_core_fields
    return nil if parent_element_id.blank?
    parent_element = FormElement.find(parent_element_id)
    
    fields_in_use = []
    parent_element.children_by_type("CoreFieldElement").each { |field| fields_in_use << field.name }
    
    available_core_fields = []
    Event.exposed_attributes.each do |attribute|
      unless (fields_in_use.include?(attribute[1][:name]))
        field_attributes = [ attribute[1][:name], attribute[0]]
        available_core_fields << field_attributes
      end
    end
    
    available_core_fields
  end
  
end

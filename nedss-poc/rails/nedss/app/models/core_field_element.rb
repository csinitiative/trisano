class CoreFieldElement < FormElement
  
  attr_accessor :parent_element_id
  validates_presence_of :name
  
  def available_core_fields
    return nil if parent_element_id.blank?
    parent_element = FormElement.find(parent_element_id)
    fields_in_use = []
    parent_element.children_by_type("CoreFieldElement").each { |field| fields_in_use << field.name }
    Event.exposed_attributes.collect { |field| if (!fields_in_use.include?(field[1][:name]))
        field
      end
    }.compact
  end
  
end

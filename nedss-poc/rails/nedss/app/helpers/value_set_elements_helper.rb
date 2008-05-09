module ValueSetElementsHelper
  
  def add_value_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, 'value-mods', :partial => 'value_set_elements/value_element', :object => ValueElement.new
    end
  end
  
  
  def fields_for_value_element(value_element, &block)
    prefix = value_element.new_record? ? 'new' : 'existing'
    fields_for("value_set_element[#{prefix}_value_element_attributes][]", value_element, &block)
  end

  
end

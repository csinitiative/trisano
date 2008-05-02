module ValueSetElementsHelper
  
  def add_value_link(name)
    link_to_function name do |page|
      page.insert_html :bottom, 'value-mods', :partial => 'value_set_elements/value', :object => ValueElement.new
    end
  end
  
end

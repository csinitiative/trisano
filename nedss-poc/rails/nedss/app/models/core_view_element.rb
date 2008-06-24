class CoreViewElement < FormElement
  
  attr_accessor :parent_element_id
  
  validates_presence_of :name
  
  def available_core_views
    return nil if parent_element_id.blank?
    parent_element = FormElement.find(parent_element_id)
    names_in_use = []
    parent_element.children_by_type("CoreViewElement").each { |view| names_in_use << view.name }
    core_views.collect { |core_view| if (!names_in_use.include?(core_view[0]))
        core_view
      end
    }.compact
  end
  
  private
  
  def core_views
    [
      ["Demographics", "Demographics"], 
      ["Clinical", "Clinical"], 
      ["Laboratory", "Laboratory"], 
      ["Contacts", "Contacts"],
      ["Epidemiological", "Epidemiological"], 
      ["Reporting", "Reporting"], 
      ["Administrative", "Administrative"]
    ]
  end
  
end

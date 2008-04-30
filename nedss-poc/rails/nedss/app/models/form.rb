class Form < ActiveRecord::Base
  belongs_to :disease
  belongs_to :jurisdiction, :class_name => "Entity", :foreign_key => "jurisdiction_id"
  
  has_one :form_base_element, :class_name => "FormElement"
  
  after_create :initialize_form_elements
  
  def self.get_investigation_forms(disease_id, jurisdiction_id)
    find_all_by_disease_id(disease_id, :conditions => ["jurisdiction_id = ? OR jurisdiction_id IS NULL", jurisdiction_id])
  end

  private
  def initialize_form_elements
    form_base_element = FormBaseElement.create({:form_id => self.id})
    default_view_element = ViewElement.create({:form_id => self.id, :name => "Default View"})
    form_base_element.add_child(default_view_element)
    default_section_element = SectionElement.create({:form_id => self.id, :name => "Default Section"})
    default_view_element.add_child(default_section_element)
  end
  
end

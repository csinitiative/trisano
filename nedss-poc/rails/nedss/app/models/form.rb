class Form < ActiveRecord::Base
  belongs_to :disease
  belongs_to :jurisdiction, :class_name => "Entity", :foreign_key => "jurisdiction_id"
  
  has_one :form_base_element, :class_name => "FormElement"
  
  after_create :initialize_form_elements
  
  def initialize_form_elements
    form_base_element = FormBaseElement.create({:form_id => self.id})
    default_view_element = ViewElement.create({:form_id => self.id})
    form_base_element.add_child(default_view_element)
  end
  
end

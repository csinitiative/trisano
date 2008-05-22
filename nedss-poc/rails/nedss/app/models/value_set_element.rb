class ValueSetElement < FormElement
  
  has_many :value_elements, :class_name => "FormElement",  :foreign_key => :parent_id
  after_update :save_all_value_elements
  
  validates_presence_of :name
  
  attr_accessor :parent_element_id
  
  def save_and_add_to_form(parent_element_id)
    if self.valid?
      transaction do
        self.save
        save_new_value_elements
        parent_element = FormElement.find(parent_element_id)
        parent_element.add_child(self)
      end
    end
  end
  
  def new_value_element_attributes=(value_attributes)
    @new_value_elements = []
    value_attributes.each do |attributes|
      value = ValueElement.new(attributes)
      @new_value_elements << value
    end
  end
    
  def existing_value_element_attributes=(value_attributes)
    value_elements.reject(&:new_record?).each do |value_element|
      attributes = value_attributes[value_element.id.to_s]
      if attributes
        value_element.attributes = attributes
      else
        value_elements.destroy(value_element)
      end
    end
  end
  
  private
  
  def save_new_value_elements
    unless @new_value_elements.nil?
      @new_value_elements.each do |a|
        a.form_id = self.form_id
        a.tree_id = self.tree_id
        a.save
        self.add_child a
      end
    end
  end
  
  def save_all_value_elements
    value_elements.each do |value_element|
      value_element.save(false)
    end
    save_new_value_elements
  end
  
end

class CoreViewElement < FormElement
  
  validates_presence_of :name, :form_id
  
  def save_and_add_to_form
    if self.valid?
      transaction do
        self.save
        form = Form.find(self.form_id)
        form.form_base_element.add_child(self)
      end
    end
  end
  
end

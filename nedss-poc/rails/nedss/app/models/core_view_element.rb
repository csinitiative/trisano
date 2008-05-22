class CoreViewElement < FormElement
  
  validates_presence_of :name, :form_id
  
  def save_and_add_to_form
    if self.valid?
      transaction do
        form = Form.find(self.form_id)
        self.tree_id = form.form_base_element.tree_id
        self.save
        form.form_base_element.add_child(self)
      end
    end
  end
  
end

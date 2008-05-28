class ViewElement < FormElement

  validates_presence_of :name, :form_id

  # Debt? This is a dup of what's in core_view_element.rb. Other elements are more specialized. Consider refactoring.
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

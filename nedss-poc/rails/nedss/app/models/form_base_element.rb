class FormBaseElement < FormElement
  belongs_to :form

  def save_and_add_to_form
    return nil
  end
  
end


def create_form(event_type, form_name, form_short_name, disease)
  form = Form.new
  form.event_type = event_type + "_event"
  form.name = form_name
  form.short_name = form_short_name
  form.disease_ids = [Disease.find_by_disease_name(disease).id]
  form.save_and_initialize_form_elements
  form
end

def create_published_form(event_type, form_name, disease)
  form = create_form(event_type, form_name, disease)
  form.publish
end

def save_new_form(form_name)
  submit_form "new_form"
  response.should contain("Form was successfully created.")
  response.should contain(form_name)
end

def log_in_as(user)
  visit home_path unless current_url
  select user, :from => "user_id"
  submit_form "switch_user"
end

def create_basic_event(event_type, last_name, disease=nil, jurisdiction=nil)
  returning Kernel.const_get(event_type.capitalize + "Event").new do |event|
    event.attributes = { :event_status => "NEW", :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => last_name } } } }
    event.build_disease_event(:disease_id => Disease.find_by_disease_name(disease).id) if disease
    j = jurisdiction || "Unassigned"
    event.build_jurisdiction(:secondary_entity_id => Place.find_by_short_name_and_place_type_id(j, Code.find_by_code_name_and_the_code('placetype', 'J')).entity_id)
    event.get_investigation_forms  # If there are any, we might want em
    event.save!
  end
end

def create_published_form(event_type, form_name, disease)
  form = Form.new
  form.event_type = event_type + "_event"
  form.name = form_name
  form.disease_ids = [Disease.find_by_disease_name(disease).id]
  form.save_and_initialize_form_elements
  form.publish
end

def add_child_to_event(event, child_last_name)
  returning event.contact_child_events.build do |child|
    child.attributes = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => child_last_name } } } }
    event.save!
    child.get_investigation_forms
    child.save
  end
end

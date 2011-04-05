module EventsSpecHelper

  def given_a_morb_with_disease(disease)
    Factory.create(:morbidity_event, :disease_event => Factory.create(:disease_event, :disease => disease))
  end

  def given_a_contact_for_morb(morb, options={})
    returning Factory.create(:contact_event, options) do |contact|
      contact.update_attributes!(:parent_event => morb)
    end
  end

  def given_a_contact_with_disease(disease)
    morb = given_a_morb_with_disease disease
    contact = given_a_contact_for_morb morb
    contact.create_disease_event :disease => disease
    contact
  end
  
  def add_contact_to_event(event, contact_last_name)
    returning event.contact_child_events.build do |child|
      child.attributes = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => contact_last_name } } } }
      event.save!
      child.save
    end
  end

  def add_place_to_event(event, name)
    returning event.place_child_events.build do |child|
      child.attributes = { :interested_place_attributes => { :place_entity_attributes => { :place_attributes => { :name => name } } } }
      event.save!
      child.save
      code = Code.placetypes.active.find_by_the_code('S')
      child.interested_place.place_entity.place.place_types << code unless code.nil?
    end
  end

  def add_lab_to_event(event, lab_name_or_lab_place_entity, lab_result_attributes={})
    lab_place_entity = lab_name_or_lab_place_entity.is_a?(PlaceEntity) ? lab_name_or_lab_place_entity : create_lab!(lab_name_or_lab_place_entity)
    lab_result = Factory.create(:lab_result, lab_result_attributes)
    lab = Factory.create(:lab, :secondary_entity => lab_place_entity, :lab_results => [lab_result])
    event.labs << lab
    lab
  end

  def add_treatment_to_event(event, treatment_attributes={})
    treatment = Factory.create(:participations_treatment, treatment_attributes)
    event.interested_party.treatments << treatment
    treatment
  end

  def add_hospitalization_facility_to_event(event, hospital_name, hospitals_participations_attributes={})
    hospital_place_entity = create_hospitalization_facility!(hospital_name)
    hospitals_participation = Factory.create(:hospitals_participation, hospitals_participations_attributes)
    hospitalization_facility = Factory.create(:hospitalization_facility,
                                              :place_entity => hospital_place_entity,
                                              :hospitals_participation => hospitals_participation
    )
    event.hospitalization_facilities << hospitalization_facility
    hospitalization_facility
  end

  def create_lab!(name)
    existing_lab = Place.labs_by_name(name).first
    return existing_lab.entity unless existing_lab.nil?
    create_place_entity!(name, :lab)
  end

  def create_hospitalization_facility!(name)
    create_place_entity!(name, :hospitalization)
  end

  def create_diagnostic_facility!(name)
    create_place_entity!(name, :diagnostic)
  end

  def create_reporting_agency!(name)
    create_place_entity!(name, :agency)
  end

  def create_place_exposure!(name)
    place_event = Factory.build(:place_event)
    the_code = Place.epi_type_codes.first
    type = Code.find_or_create_by_code_name_and_the_code('placetype', the_code)
    place = place_event.interested_place.place_entity.place
    place.name = name
    place.place_types << type
    place_event.save!
  end

  def create_place_entity!(name, type)
    place_entity = Factory.build(:place_entity)
    place_entity.place.name = name
    begin
      the_code = Place.send("#{type.to_s}_type_codes").first
    rescue NoMethodError => e
      the_code = type
    end
    place_entity.place.place_types << create_code!('placetype', the_code)
    place_entity.save!
    place_entity
  end

  def create_patient!(name)
    first_name, last_name = split_name(name)
    morbidity_event = Factory.build(:morbidity_event)
    person = morbidity_event.interested_party.person_entity.person
    person.first_name = first_name
    person.last_name = last_name
    morbidity_event .save!
    morbidity_event
  end

  def create_contact!(name)
    first_name, last_name = split_name(name)
    contact_event = Factory.build(:contact_event)
    person = contact_event.interested_party.person_entity.person
    person.first_name = first_name
    person.last_name = last_name
    contact_event.save!
    contact_event
  end

  def create_clinician!(name)
    first_name, last_name = split_name(name)
    morbidity_event = Factory.build(:morbidity_event)
    clinician = Factory.build(:clinician, :first_name => first_name, :last_name => last_name)
    clinician_entity = Factory.build(:person_entity)
    clinician_entity.person = clinician
    morbidity_event.clinicians << Clinician.new(:person_entity => clinician_entity)
    morbidity_event.save!
  end

  def create_reporter!(name)
    first_name, last_name = split_name(name)
    morbidity_event = Factory.build(:morbidity_event)
    reporter = Factory.build(:person, :first_name => first_name, :last_name => last_name)
    reporter_entity = Factory.build(:person_entity)
    reporter_entity.person = reporter
    morbidity_event.reporter = Reporter.new(:person_entity => reporter_entity)
    morbidity_event.save!
  end

  def split_name(name)
    name_one, name_two = name.split(" ")
    name_two.nil? ? (last_name = name_one; first_name = nil) : (last_name = name_two; first_name = name_one)
    return first_name, last_name
  end

  def create_code!(code_name, the_code)
    code = Code.find_by_code_name_and_the_code(code_name, the_code)
    code = Factory.create(:code, :code_name => code_name, :the_code => the_code) unless code
    code
  end

  def human_event_with_demographic_info!(type, demographic_info={ :last_name => Factory.next(:last_name) })
    returning Factory.build(type) do |event|
      event.update_attributes!({
                                 :jurisdiction_attributes => {
                                   :secondary_entity_id => Place.unassigned_jurisdiction.try(:entity_id)},
                                 :interested_party_attributes => {
                                   :person_entity_attributes => {
                                     :person_attributes => demographic_info
                                   }}})
    end
  end

  def searchable_event!(type, last_name)
    returning Factory.build(type) do |event|
      event.update_attributes!({
                                 :jurisdiction_attributes => {
                                   :secondary_entity_id => Place.unassigned_jurisdiction.try(:entity_id)},
                                 :interested_party_attributes => {
                                   :person_entity_attributes => {
                                     :person_attributes => {
                                       :last_name => last_name}}}})
    end
  end

  def searchable_person!(last_name)
    returning Factory.build(:person_entity) do |person|
      person.update_attributes!({
                                  :person_attributes => {
                                    :last_name => last_name}})
    end
  end

  def disease!(disease_name)
    disease = Disease.find_by_disease_name(disease_name)
    unless disease
      disease = Factory.create(:disease, :disease_name => disease_name)
    end
    disease
  end

  def hospital_place_type
    Code.find_or_create_by_the_code_and_code_name({
                                                    :the_code => 'H',
                                                    :code_name => 'placetype',
                                                    :code_description => 'Hospital'
                                                  })
  end
end

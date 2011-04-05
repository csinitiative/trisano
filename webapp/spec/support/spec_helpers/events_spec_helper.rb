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
      unassigned_jurisdiction_entity_id = Place.unassigned_jurisdiction(true).try(:entity_id) || create_unassigned_jurisdiction_entity.id
      event.update_attributes!({
                                 :jurisdiction_attributes => {
                                   :secondary_entity_id => unassigned_jurisdiction_entity_id
                                 },
                                 :interested_party_attributes => {
                                   :person_entity_attributes => {
                                     :person_attributes => demographic_info
                                   }}})
    end
  end

  def searchable_event!(type, last_name)
    returning Factory.build(type) do |event|
      unassigned_jurisdiction_entity_id = Place.unassigned_jurisdiction(true).try(:entity_id) || create_unassigned_jurisdiction_entity.id
      event.update_attributes!({
                                 :jurisdiction_attributes => {
                                   :secondary_entity_id => unassigned_jurisdiction_entity_id
                                 },
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

  def mock_event
    event = Factory.build(:morbidity_event)
    person = mock_person_entity

    imported_from = Factory.build(:external_code)
    state_case_status = Factory.build(:external_code)
    lhd_case_status = Factory.build(:external_code)
    outbreak_associated = Factory.build(:code)
    hospitalized = Factory.build(:external_code)
    died = Factory.build(:external_code)
    pregnant = Factory.build(:external_code)
    specimen_source = Factory.build(:external_code)
    specimen_sent_to_state = Factory.build(:external_code)

    disease_event = Factory.build(:disease_event)
    disease = Factory.build(:disease)
    lab_result = Factory.build(:lab_result)
    answer = Factory.build(:answer)

    jurisdiction = Factory.build(:jurisdiction)
    interested_party = Factory.build(:interested_party)
    lab = Factory.build(:lab)
    diagnostic = Factory.build(:diagnostic_facility)
    hospital = Factory.build(:hospitalization_facility)

    disease.stubs(:disease_id).returns(1)
    disease.stubs(:disease_name).returns("Bubonic,Plague")
    disease.stubs(:treatment_lead_in).returns("")
    disease.stubs(:place_lead_in).returns("")
    disease.stubs(:contact_lead_in).returns("")

    imported_from.stubs(:code_description).returns('Utah')
    state_case_status.stubs(:code_description).returns('Confirmed')
    lhd_case_status.stubs(:code_description).returns('Confirmed')
    outbreak_associated.stubs(:code_description).returns('Yes')
    hospitalized.stubs(:code_description).returns('Yes')
    died.stubs(:code_description).returns('No')
    pregnant.stubs(:code_description).returns('No')

    jurisdiction.stubs(:secondary_entity_id).returns(75)

    interested_party.stubs(:primary_entity).returns(1)
    interested_party.stubs(:person_entity).returns(person)

    disease_event.stubs(:disease_id).returns(1)
    disease_event.stubs(:hospital_id).returns(13)
    disease_event.stubs(:hospitalized).returns(hospitalized)
    disease_event.stubs(:hospitalized_id).returns(1401)
    disease_event.stubs(:died_id).returns(1401)
    disease_event.stubs(:died).returns(died)
    disease_event.stubs(:pregnant).returns(pregnant)
    disease_event.stubs(:disease).returns(disease)
    disease_event.stubs(:date_diagnosed).returns("2008-02-15")
    disease_event.stubs(:disease_onset_date).returns("2008-02-13")
    disease_event.stubs(:pregnant_id).returns(1401)
    disease_event.stubs(:pregnancy_due_date).returns("")

    specimen_source.stubs(:code_description).returns('Tissue')
    specimen_sent_to_state.stubs(:code_description).returns('Yes')

    lab_result.stubs(:specimen_source_id).returns(1501)
    lab_result.stubs(:specimen_source).returns(specimen_source)
    lab_result.stubs(:collection_date).returns("2008-02-14")
    lab_result.stubs(:lab_test_date).returns("2008-02-15")

    lab_result.stubs(:specimen_sent_to_state_id).returns(1401)
    lab_result.stubs(:specimen_sent_to_state).returns(specimen_sent_to_state)

    event.stubs(:all_jurisdictions).returns([jurisdiction])
    event.stubs(:labs).returns([lab])
    event.stubs(:diagnosing_health_facilities).returns([diagnostic])
    event.stubs(:hospitalized_health_facilities).returns([hospital])
    event.stubs(:jurisdiction).returns(jurisdiction)
    event.stubs(:interested_party).returns(interested_party)
    event.stubs(:record_number).returns("2008537081")
    event.stubs(:event_name).returns('Test')
    event.stubs(:event_onset_date).returns("2008-02-19")
    event.stubs(:disease_event).returns(disease_event)
    event.stubs(:lab_result).returns(lab_result)
    event.stubs(:event_status).returns("NEW")
    event.stubs(:imported_from_id).returns("2101")
    event.stubs(:imported_from).returns(imported_from)
    event.stubs(:state_case_status_id).returns(1801)
    event.stubs(:lhd_case_status_id).returns(1801)
    event.stubs(:state_case_status).returns(state_case_status)
    event.stubs(:lhd_case_status).returns(lhd_case_status)
    event.stubs(:outbreak_associated_id).returns(1401)
    event.stubs(:outbreak_associated).returns(outbreak_associated)
    event.stubs(:outbreak_name).returns("Test Outbreak")
    event.stubs(:investigation_started_date).returns("2008-02-05")
    event.stubs(:investigation_completed_LHD_date).returns("2008-02-08")
    event.stubs(:review_completed_by_state_date).returns("2008-02-11")
    event.stubs(:first_reported_PH_date).returns("2008-02-07")
    event.stubs(:results_reported_to_clinician_date).returns("2008-02-08")
    event.stubs(:MMWR_year).returns("2008")
    event.stubs(:MMWR_week).returns("7")
    event.stubs(:answers).returns([answer])
    event.stubs(:form_references).returns([])
    event.stubs(:under_investigation?).returns(true)
    event.stubs(:interested_party=)
    event.stubs(:get_investigation_forms).returns(nil)
    event.stubs(:safe_call_chain).with(:disease_event, :disease, :disease_name).returns("Bubonic,Plague")
    event.stubs(:deleted_at).returns(nil)
    event.stubs(:updated_at).returns(Time.new)
    event
  end

  def mock_person_entity
    person = Factory.build(:person)
    person.stubs(:entity_id).returns("1")
    person.stubs(:last_name).returns("Marx")
    person.stubs(:first_name).returns("Groucho")
    person.stubs(:middle_name).returns("Julius")
    person.stubs(:birth_date).returns(Date.parse('1902-10-2'))
    person.stubs(:date_of_death).returns(Date.parse('1970-4-21'))
    person.stubs(:birth_gender_id).returns(1)
    person.stubs(:birth_gender).returns(nil)
    person.stubs(:ethnicity_id).returns(101)
    person.stubs(:primary_language_id).returns(301)
    person.stubs(:approximate_age_no_birthday).returns(50)
    person.stubs(:food_handler_id).returns(1401)
    person.stubs(:healthcare_worker_id).returns(1401)
    person.stubs(:group_living_id).returns(1401)
    person.stubs(:day_care_association_id).returns(1401)
    person.stubs(:risk_factors).returns("None")
    person.stubs(:risk_factors_notes).returns("None")

    address = Factory.build(:address)
    address.stubs(:street_number).returns("123")
    address.stubs(:street_name).returns("Elm St.")
    address.stubs(:unit_number).returns("99")
    address.stubs(:city).returns("Provo")
    address.stubs(:state_id).returns(1001)
    address.stubs(:postal_code).returns("12345")
    address.stubs(:county_id).returns(1101)

    phone = Factory.build(:telephone)
    phone.stubs(:area_code).returns("212")
    phone.stubs(:phone_number).returns("5551212")
    phone.stubs(:extension).returns("4444")

    entity = Factory.build(:person_entity)
    entity.stubs(:entity_type).returns('PersonEntity')
    entity.stubs(:person).returns(person)
    entity.stubs(:address).returns(address)
    entity.stubs(:telephone).returns(phone)
    entity.stubs(:race_ids).returns([201])
    entity
  end
  
end

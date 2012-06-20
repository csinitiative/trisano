require 'spec_helper'

describe "/_assessment_event.xml.haml" do

  before do
    event = Factory.create(:assessment_event)
    render '/assessment_events/_assessment_event.xml.haml', :locals => { :assessment_event => event }
  end

  it "should have assessment event fields" do
    [:acuity,
     :event_name,
     :other_data_1,
     :other_data_2,
     :outbreak_name,
     :parent_guardian,
     :first_reported_PH_date,
     :results_reported_to_clinician_date,
     %w(imported_from_id        https://wiki.csinitiative.com/display/tri/Relationship+-+Imported),
     %w(lhd_case_status_id      https://wiki.csinitiative.com/display/tri/Relationship+-+Case),
     %w(state_case_status_id    https://wiki.csinitiative.com/display/tri/Relationship+-+Case),
     %w(outbreak_associated_id  https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno)
    ].each do |field, rel|
      assert_xml_field("assessment-event", field, rel)
    end
  end

  it "should have the patient's address" do
    assert_address_xml_at_css('assessment-event address-attributes')
  end

  it "should have disease event data" do
    [%w(hospitalized_id  https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     %w(disease_id       https://wiki.csinitiative.com/display/tri/Relationship+-+Disease),
     :disease_onset_date,
     :date_diagnosed,
     %w(died_id          https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno)
    ].each do |field, rel|
      assert_xml_field("assessment-event disease-event-attributes", field, rel)
    end
  end

  it "should have jurisdiction data" do
    assert_xml_field "assessment-event jurisdiction-attributes", "secondary-entity-id", "https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction"
  end
  
  it "should have risk factor data" do
    [:occupation,
     %w(healthcare_worker_id https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     :pregnancy_due_date,
     :risk_factors_notes,
     %w(food_handler_id https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     %w(group_living_id https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     :risk_factors,
     %w(pregnant_id https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     %w(day_care_association_id https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno)
    ].each do |field, rel|
      assert_xml_field("assessment-event interested-party-attributes risk-factor-attributes", field, rel)
    end
  end

  it "should have the patient's demographics data" do
    [:birth_date,
     :first_name,
     :middle_name,
     :last_name,
     %w(ethnicity_id https://wiki.csinitiative.com/display/tri/Relationship+-+Ethnicity),
     :date_of_death,
     %w(birth_gender_id https://wiki.csinitiative.com/display/tri/Relationship+-+Gender),
     %w(primary_language_id https://wiki.csinitiative.com/display/tri/Relationship+-+Language)
    ].each do |field, rel|
      assert_xml_field('assessment-event interested-party-attributes person-entity-attributes person-attributes', field, rel)
    end
    assert_xml_field 'assessment-event interested-party-attributes person-entity-attributes', :race_ids, 'https://wiki.csinitiative.com/display/tri/Relationship+-+Race'
  end

  it "should have the patient's phone and email information" do
    assert_telephone_xml_at_css('assessment-event interested-party-attributes person-entity-attributes telephones-attributes i0')
    assert_xml_field('assessment-event interested-party-attributes person-entity-attributes email-addresses-attributes i0', 'email-address')
  end

  it "should have reporter data" do
    [:last_name, :first_name].each do |field, rel|
      assert_xml_field('assessment-event reporter-attributes person-entity-attributes person-attributes', field, rel)
    end
    assert_telephone_xml_at_css('assessment-event reporter-attributes person-entity-attributes telephones-attributes i0')
  end

  it "should have reporting agency data" do
    [:name,
     %w(place_type_ids https://wiki.csinitiative.com/display/tri/Relationship+-+PlaceType)
    ].each do |field, rel|
      assert_xml_field('assessment-event reporting-agency-attributes place-entity-attributes place-attributes', field, rel)
    end
    assert_telephone_xml_at_css('assessment-event reporting-agency-attributes place-entity-attributes telephones-attributes i0')
  end

  it "should have nested notes data" do
    [:note_type, :note].each do |field, rel|
      assert_xml_field('assessment-event notes-attributes i0', field, rel)
    end
  end

  it "should have hospitalization facility data" do
    assert_xml_field('assessment-event hospitalization-facilities-attributes i0', 'secondary_entity_id', 'https://wiki.csinitiative.com/display/tri/Relationship+-+Hospitalization')
    [:admission_date, :discharge_date, :medical_record_number].each do |field, rel|
      assert_xml_field('assessment-event hospitalization-facilities-attributes i0 hospitals-participation-attributes', field, rel)
    end
  end

  it "should have treatment data" do
    [%w(treatment_id https://wiki.csinitiative.com/display/tri/Relationship+-+Treatment),
     :treatment_date,
     :stop_treatment_date
    ].each do |field, rel|
      assert_xml_field('assessment-event interested-party-attributes treatments-attributes i0', field, rel)
    end
  end

  it "should have clinician data" do
    [:last_name, :first_name, :middle_name, :person_type].each do |field, rel|
      assert_xml_field('assessment-event clinicians-attributes i0 person-entity-attributes person-attributes', field, rel)
    end
    assert_telephone_xml_at_css('assessment-event clinicians-attributes i0 person-entity-attributes telephones-attributes i0')
  end

  it "should have lab data" do
    assert_xml_field('assessment-event labs-attributes i0', 'secondary-entity-id', 'https://wiki.csinitiative.com/display/tri/Relationship+-+Lab')
    [%w(specimen_source_id https://wiki.csinitiative.com/display/tri/Relationship+-+SpecimenSource),
     %w(specimen_sent_to_state_id https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     :reference_range,
     :collection_date,
     %w(test_status_id https://wiki.csinitiative.com/display/tri/Relationship+-+TestStatus),
     %w(test_result_id https://wiki.csinitiative.com/display/tri/Relationship+-+TestResult),
     :lab_test_date,
     %w(test_type_id https://wiki.csinitiative.com/display/tri/Relationship+-+TestType),
     :units,
     :result_value,
     %w(organism_id https://wiki.csinitiative.com/display/tri/Relationship+-+Organism),
     :comment
    ].each do |field, rel|
      assert_xml_field('assessment-event labs-attributes i0 lab-results-attributes i0', field, rel)
    end
  end

  it "should have diagnostic facilities data" do
    assert_xml_field('assessment-event diagnostic-facilities-attributes i0', 'secondary_entity_id', 'https://wiki.csinitiative.com/display/tri/Relationship+-+DiagnosticFacility')
    [:name,
     %w(place_type_ids https://wiki.csinitiative.com/display/tri/Relationship+-+PlaceType)
    ].each do |field, rel|
      assert_xml_field('assessment-event diagnostic-facilities-attributes i0 place-entity-attributes place-attributes', field, rel)
    end
  end

  it "should have child place event data" do
    assert_xml_field('assessment-event place-child-events-attributes i0 participations-place-attributes', 'date-of-exposure')
    [:name,
     %w(place_type_ids https://wiki.csinitiative.com/display/tri/Relationship+-+PlaceType)
    ].each do |field, rel|
      assert_xml_field('assessment-event place-child-events-attributes i0 interested-place-attributes place-entity-attributes place-attributes', field, rel)
    end
    assert_address_xml_at_css('assessment-event place-child-events-attributes i0 interested-place-attributes place-entity-attributes canonical-address-attributes')
  end
end

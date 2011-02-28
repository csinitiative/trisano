require 'spec_helper'

describe "/_morbidity_event.xml.haml" do
  include XmlSpecHelper

  before do
    event = Factory.create(:morbidity_event)
    render '/morbidity_events/_morbidity_event.xml.haml', :locals => { :morbidity_event => event }
  end

  it "should have morbidity event fields" do
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
      assert_xml_field("morbidity-event", field, rel)
    end
  end

  it "should have the patient's address" do
    [['state_id',  'https://wiki.csinitiative.com/display/tri/Relationship+-+State'],
     ['county_id', 'https://wiki.csinitiative.com/display/tri/Relationship+-+County'],
     'unit_number',
     'postal_code',
     'street_name',
     'street_number',
     'city'
    ].each do |field, rel|
      assert_xml_field("morbidity-event address-attributes", field, rel)
   end
  end

  it "should have disease event data" do
    [%w(hospitalized_id  https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     %w(disease_id       https://wiki.csinitiative.com/display/tri/Relationship+-+Disease),
     :disease_onset_date,
     :date_diagnosed,
     %w(died_id          https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno)
    ].each do |field, rel|
      assert_xml_field("morbidity-event disease-event-attributes", field, rel)
    end
  end

  it "should have jurisdiction data" do
    assert_xml_field "morbidity-event jurisdiction-attributes", "secondary-entity-id", "https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction"
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
      assert_xml_field("morbidity-event interested-party-attributes risk-factor-attributes", field, rel)
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
      assert_xml_field('morbidity-event interested-party-attributes person-entity-attributes person-attributes', field, rel)
    end
    assert_xml_field 'morbidity-event interested-party-attributes person-entity-attributes', :race_ids, 'https://wiki.csinitiative.com/display/tri/Relationship+-+Race'
  end

  it "should have reporter data" do
    [:last_name, :first_name].each do |field, rel|
      assert_xml_field('morbidity-event reporter-attributes person-entity-attributes person-attributes', field, rel)
    end
  end

  it "should have reporting agency data" do
    [:name,
     %w(place_type_ids https://wiki.csinitiative.com/display/tri/Relationship+-+PlaceType)
    ].each do |field, rel|
      assert_xml_field('morbidity-event reporting-agency-attributes place-entity-attributes place-attributes', field, rel)
    end
  end
end

require 'spec_helper'

describe "/_morbidity_event.xml.haml" do
  before do
    event = Factory.create(:morbidity_event)
    render '/morbidity_events/_morbidity_event.xml.haml', :locals => { :morbidity_event => event }
  end

  def assert_field(css_path, field, rel=nil)
    if rel
     response.body.should have_css("#{css_path} #{field.to_s.dasherize}[rel='#{rel}']")
     response.body.should have_css("morbidity-event atom|link[rel='#{rel}']")
    else
     response.body.should have_css("#{css_path} #{field.to_s.dasherize}")
    end
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
      assert_field("morbidity-event", field, rel)
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
      assert_field("morbidity-event address-attributes", field, rel)
   end
  end

  it "should have disease event data" do
    [%w(hospitalized_id  https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno),
     %w(disease_id       https://wiki.csinitiative.com/display/tri/Relationship+-+Disease),
     :disease_onset_date,
     :date_diagnosed,
     %w(died_id          https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno)
    ].each do |field, rel|
      assert_field("morbidity-event disease-event-attributes", field, rel)
    end
  end

  it "should have jurisdiction data" do
    assert_field "morbidity-event jurisdiction-attributes", "secondary-entity-id", "https://wiki.csinitiative.com/display/tri/Relationship+-+Jurisdiction"
  end

  it "should include the patient's last name" do
    response.should have_tag 'morbidity-event interested-party-attributes person-entity-attributes person-attributes last-name'
  end

  it "should have race tags" do
    response.should have_tag 'morbidity-event interested-party-attributes person-entity-attributes' do
      with_tag 'race-ids'
      with_tag '[rel=?]', 'https://wiki.csinitiative.com/display/tri/Relationship+-+Race'
    end
  end
end

require 'spec_helper'

describe "/_morbidity_event.xml.haml" do
  before do
    event = Factory.create(:morbidity_event)
    render '/morbidity_events/_morbidity_event.xml.haml', :locals => { :morbidity_event => event }
  end

  it "should have morbidity event fields" do
    fields = %w(acuity event_name other_data_1 other_data_2 outbreak_name parent_guardian first_reported_PH_date results_reported_to_clinician_date)
    fields.each do |field|
      response.should have_tag("morbidity-event #{field.dasherize}")
    end
  end

  it "should have morbidity event codes as relations" do
    [%w(imported_from_id        https://wiki.csinitiative.com/display/tri/Relationship+-+Imported),
     %w(lhd_case_status_id      https://wiki.csinitiative.com/display/tri/Relationship+-+Case),
     %w(state_case_status_id    https://wiki.csinitiative.com/display/tri/Relationship+-+Case),
     %w(outbreak_associated_id  https://wiki.csinitiative.com/display/tri/Relationship+-+Yesno)
    ].each do |field, rel|
      response.body.should have_css("morbidity-event #{field.dasherize}[rel='#{rel}']")
      response.body.should have_css("morbidity-event atom|link[rel='#{rel}']")
    end
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

require 'spec_helper'

describe "/_morbidity_event.xml.haml" do
  before do
    event = Factory.create(:morbidity_event)
    render '/morbidity_events/_morbidity_event.xml.haml', :locals => { :morbidity_event => event }
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

require 'spec_helper'

describe "/_morbidity_event.xml.erb" do
  before do
    event = Factory.create(:morbidity_event)
    render '/morbidity_events/_morbidity_event.xml.erb', :locals => { :morbidity_event => event }
  end

  it "should include the patient's last name" do
    response.should have_tag 'morbidity-event interested-party-attributes person-entity-attributes person-attributes last-name'
  end

  it "should have a link to race options" do
    response.should have_tag 'morbidity-event interested-party-attributes person-entity-attributes' do
      with_tag '[rel=?]', 'http://trisano.org/api/rels/race'
    end
  end
end

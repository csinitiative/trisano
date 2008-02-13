require File.dirname(__FILE__) + '/../../spec_helper'

describe "/lab_events/index.csv.haml" do
  before(:each) do
    lab_event_98 = mock_model(LabEvent, :event_name => 'Test', :event_onset_date => '2008-02-07', :event_status => 'Open')

    assigns[:lab_events] = [lab_event_98]
  end

  it "should render a csv template of the lab_events" do
    render "/lab_events/index.csv.haml"
  end

  it "should render a csv in event_name,event_onset_date,event_status for a Test event" do
    render "/lab_events/index.csv.haml"
    response.should have_text(/Test,2008-02-07,Open$/)
  end

  it "should render a header column for with event_name,event_onset_date,event_status" do
    render "/lab_events/index.csv.haml"
    response.should have_text(/^event_name,event_onset_date,event_status/)
  end

  it "should render a csv in event_name,event_onset_date,event_status format" do
    render "/lab_events/index.csv.haml"
    response.should have_text("event_name,event_onset_date,event_status\nTest,2008-02-07,Open\n")
  end

end

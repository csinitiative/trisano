require File.dirname(__FILE__) + '/../../spec_helper'


describe "/events/index.csv.haml" do
  
  before(:each) do
    assigns[:events] = [mock(Event), mock(Event)]
  end

  it "should render a csv template of events" do
    template.should_receive(:render_events_csv).exactly(1).times
    render "events/index.csv.haml"
  end

end

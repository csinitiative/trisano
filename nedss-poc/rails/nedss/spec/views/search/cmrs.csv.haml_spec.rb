require File.dirname(__FILE__) + '/../../spec_helper'

describe "search/cmrs.csv.haml" do
  
  before(:each) do    
    cmr = mock("record_1")
    assigns[:cmrs] = [cmr, cmr]
  end

  it "should render a csv template of events" do
    template.should_receive(:find_event).twice.and_return mock(Event)
    template.should_receive(:render_events_csv).exactly(1).times.and_yield(nil).and_yield(nil)
    render "search/cmrs.csv.haml"
  end

end

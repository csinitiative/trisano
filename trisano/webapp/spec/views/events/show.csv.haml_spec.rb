require File.dirname(__FILE__) + '/../../spec_helper'


describe "/morbidity_events/show.csv.haml" do

  before(:each) do
    assigns[:event] = nil
  end

  it "should render a csv event template" do
    template.should_receive(:render_events_csv).exactly(1).times
    render "morbidity_events/show.csv.haml"
  end

end

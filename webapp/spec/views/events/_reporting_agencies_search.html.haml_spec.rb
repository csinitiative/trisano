require 'spec_helper'

describe "events/_reporting_agencies_search.html.haml" do

  it "includes the event_id in Add links" do
    reporting_places = [ Factory(:place, :entity => create_reporting_agency!('Some Lab')) ]
    reporting_places.stubs(:total_pages).returns(1)
    assigns[:event] = Factory(:morbidity_event)
    assigns[:places] = reporting_places

    render
    response.should have_tag("a[onclick*='event_id']")
  end
end

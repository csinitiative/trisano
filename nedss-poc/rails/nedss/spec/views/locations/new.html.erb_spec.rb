require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/location_form_spec_helper'

describe "/locations/new.html.erb" do
  include LocationsHelper
  include LocationFormSpecHelper
  
  it_should_behave_like "a location form"

  before(:each) do
    @address.stub!(:new_record?).and_return(true)
  end

  def do_render
    render "/locations/new.html.erb"
  end

  it "should render new form" do
    do_render
    
    response.should have_tag("form[action=?][method=post]", person_locations_path(@person_id)) do
    end
  end
end

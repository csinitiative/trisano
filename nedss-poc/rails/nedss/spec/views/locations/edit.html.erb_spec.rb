require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/location_form_spec_helper'

describe "/locations/edit.html.erb" do
  include LocationsHelper
  include LocationFormSpecHelper

  it_should_behave_like "a location form"
  
  def do_render
    render "/locations/edit.html.erb"
  end

  it "should render edit form" do
    do_render
    
    response.should have_tag("form[action=#{person_location_path(@person_entity.id, @location.id)}][method=post]") do
    end
  end
end



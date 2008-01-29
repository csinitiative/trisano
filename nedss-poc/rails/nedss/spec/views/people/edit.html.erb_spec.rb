require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/person_form_spec_helper'

describe "/people/edit.html.erb" do
  include PeopleHelper
  include PersonFormSpecHelper
  
  it_should_behave_like "a person form"

  def do_render
    render "/people/edit.html.erb"
  end

  it "should render edit form" do
    do_render

    response.should have_tag("form[action=#{person_path(@person.entity_id)}][method=post]") do
    end
  end
end

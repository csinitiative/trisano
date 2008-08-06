require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/person_form_spec_helper'

describe "/people/edit.html.erb" do
  include EntitiesHelper
  include PersonFormSpecHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')

  def do_render
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
    render "/entities/edit.html.erb"
  end

  it_should_behave_like "a person form"

  it "should render edit form" do
    do_render
    response.should have_tag("form[action=#{entity_path(@entity)}][method=post]") do
      with_tag("input[name=?][value=?]", "_method", "put")
    end
  end
end

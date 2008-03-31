require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/person_form_spec_helper'

describe "/people/new.html.erb" do
  include EntitiesHelper
  include PersonFormSpecHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')

  def do_render
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
    render "/entities/new.html.erb"
  end

  it_should_behave_like "a person form"

  before(:each) do
    @entity.stub!(:new_record?).and_return(true)
  end

  it "should render new person form" do
    do_render
    response.should have_tag("form[action=?][method=post]", entities_path) do
    end
  end

# Uncomment this test when places, animals, etc. is implemented

#  it "should link back to various indexes" do
#    do_render
#    response.should have_tag("a[href=/entities?type=person]")
#    response.should have_tag("a[href=/entities?type=animal]")
#    response.should have_tag("a[href=/entities?type=material]")
#    response.should have_tag("a[href=/entities?type=place]")
#  end

end



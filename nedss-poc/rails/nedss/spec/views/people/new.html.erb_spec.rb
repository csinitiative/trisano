require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/person_form_spec_helper'

describe "/people/new.html.erb" do
  include PeopleHelper
  include PersonFormSpecHelper

  it_should_behave_like "a person form"
  
  before(:each) do
    @person.stub!(:new_record?).and_return(true)
  end

  def do_render
    render "/people/new.html.erb"
  end

  it "should render new person form" do
    do_render

    response.should have_tag("form[action=?][method=post]", people_path)
  end
end



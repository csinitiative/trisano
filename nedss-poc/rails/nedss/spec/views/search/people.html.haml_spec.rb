require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/people.html.haml" do
  
  def do_render
    render "/search/people.html.haml"
  end
  
  it "should render a search form" do
    do_render
    response.should have_tag("form[action=?][method=get]", search_path + "/people")
  end
  
  it "should show results when results are present" do
    person = mock_model(Person)
    person.stub!(:first_name).and_return("John")
    person.stub!(:last_name).and_return("Otter")
    person.stub!(:entity_id).and_return(1234)
    person.stub!(:birth_date).and_return(nil)
    assigns[:people] = [person]
    do_render
    response.should have_tag("h3", "Results")
  end
  
  it "should show message and link to create new CMR when no results are present" do
    assigns[:people] = []
    params[:name] = "Notaperson"
    do_render
    response.should have_text(/Your search returned no results./)
    response.should have_tag("a", "Start a CMR with the criteria that you searched on.")
  end
  
end

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/index.html.erb" do
  include PeopleHelper
  
  before(:each) do
    person_98 = mock_model(Person, :last_name => 'Marx', :first_name => 'Groucho')
    person_99 = mock_model(Person, :last_name => 'Silvers', :first_name => 'Phil')

    assigns[:people] = [person_98, person_99]
  end

  it "should render list of people" do
    render "/people/index.html.erb"
  end

  it "should display first_name last_name in a single element" do
    render "/people/index.html.erb"
    response.should have_tag('td', 'Groucho Marx')
  end

  it "should have rendered two patients" do
    render "/people/index.html.erb"
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', 'Groucho Marx')
        with_tag('td', 'Phil Silvers')
      end
    end
  end
end

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/index.html.erb" do
  include PeopleHelper
  
  before(:each) do
    person_98 = mock_model(Person, :entity_id => '1', :last_name => 'Marx', :first_name => 'Groucho')
    person_99 = mock_model(Person, :entity_id => '2', :last_name => 'Silvers', :first_name => 'Phil')
    entity_98 = mock_model(PersonEntity, :current => person_98)
    entity_99 = mock_model(PersonEntity, :current => person_99)

    assigns[:person_entities] = [entity_98, entity_99]
  end

  it "should render list of people" do
    render "/people/index.html.erb"
  end

  it "should display last_name first_name in a single element" do
    render "/people/index.html.erb"
    response.should have_tag('td', 'Marx, Groucho')
  end

  it "should have rendered two people" do
    render "/people/index.html.erb"
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', 'Marx, Groucho')
        with_tag('td', 'Silvers, Phil')
      end
    end
  end
end

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/entities/index.html.erb for people" do
  include EntitiesHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')
  
  before(:each) do
    person_98 = mock_model(Person, :entity_id => '1', :last_name => 'Marx', :first_name => 'Groucho')
    person_99 = mock_model(Person, :entity_id => '2', :last_name => 'Silvers', :first_name => 'Phil')
    entity_98 = mock_model(Entity, :current_person => person_98)
    entity_99 = mock_model(Entity, :current_person => person_99)

    assigns[:entities] = [entity_98, entity_99]
    assigns[:type] = 'person'
    assigns[:valid_types] = ['person', 'animal', 'place', 'material']
  end

  it "should render list of people" do
    render "/entities/index.html.erb"
  end

  it "should say that it's listing people" do
    render "/entities/index.html.erb"
    response.should have_tag('h1', 'Listing person entities')
  end

  it "should display last_name first_name in a single element" do
    render "/entities/index.html.erb"
    response.should have_tag('td', 'Marx, Groucho')
  end

  it "should have rendered two people" do
    render "/entities/index.html.erb"
    response.should have_tag('table') do
      with_tag('tr') do
        with_tag('td', 'Marx, Groucho')
        with_tag('td', 'Silvers, Phil')
      end
    end
  end

# Uncomment the next two tests when animals, materials, etc is implemented

#  it "should display a list of 'New' links" do
#    render "/entities/index.html.erb"
#    response.should have_tag("a[href=/entities/new?type=person]")
#    response.should have_tag("a[href=/entities/new?type=animal]")
#    response.should have_tag("a[href=/entities/new?type=material]")
#    response.should have_tag("a[href=/entities/new?type=place]")
#  end

#  it "should display a list of 'Index' links" do
#    render "/entities/index.html.erb"
#    response.should_not have_tag("a[href=/entities?type=person]")
#    response.should have_tag("a[href=/entities?type=animal]")
#    response.should have_tag("a[href=/entities?type=material]")
#    response.should have_tag("a[href=/entities?type=place]")
#  end
end

describe "/entities/index.html.erb for animals" do
end

describe "/entities/index.html.erb for materials" do
end

describe "/entities/index.html.erb for places" do
end

describe "/entities/index.html.erb for all" do
end

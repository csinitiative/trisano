# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/entities/index.html.erb for people" do
  include EntitiesHelper
  ActionController::Base.set_view_path(RAILS_ROOT + '/app/views/entities')
  
  before(:each) do
    person_98 = mock_model(Person, :entity_id => '1', :last_name => 'Marx', :first_name => 'Groucho')
    person_99 = mock_model(Person, :entity_id => '2', :last_name => 'Silvers', :first_name => 'Phil')
    entity_98 = mock_model(Entity, :person => person_98)
    entity_99 = mock_model(Entity, :person => person_99)

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

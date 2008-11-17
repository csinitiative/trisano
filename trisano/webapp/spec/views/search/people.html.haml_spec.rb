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

describe "/search/people.html.haml" do
  
  def do_render
    render "/search/people.html.haml"
  end
  
  it "should render a search form" do
    do_render
    response.should have_tag("form[action=?][method=get]", search_path + "/people")
  end
  
  it "should show results when results are present" do
    User.current_user.stub!(:is_entitled_to?).and_return(true)
    entity = mock_model(Entity)
    entity.stub!(:case_id).and_return(1)

    person = mock_model(Person)
    person.stub!(:first_name).and_return("John")
    person.stub!(:middle_name).and_return("J.")
    person.stub!(:last_name).and_return("Otter")
    person.stub!(:entity_id).and_return(1234)
    person.stub!(:gender).and_return("Male")
    person.stub!(:county).and_return("Salt Lake")
    person.stub!(:birth_date).and_return(nil)
    person.stub!(:entity).and_return(entity)    
    assigns[:people] = [{:person => person, :event_type => "No associated event", :event_id => nil}]
    do_render
    response.should have_tag("h3", "Results")
    response.should have_tag("a", "Start a CMR with the criteria that you searched on.")
  end
  
  it "should show message and link to create new CMR when no results are present" do
    User.current_user.stub!(:is_entitled_to?).and_return(true)
    assigns[:people] = []
    params[:name] = "Notaperson"
    do_render
    response.should have_text(/Your search returned no results./)
    response.should have_tag("a", "Start a CMR with the criteria that you searched on.")
  end
  
end

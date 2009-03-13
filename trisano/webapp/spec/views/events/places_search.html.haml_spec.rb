# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

include ApplicationHelper

describe "/events/_places_search.html.haml" do
  
  before(:each) do
    mock_user
    @place = mock_model(Place)
    @place_type = mock_model(ExternalCode)
    @county = mock_model(ExternalCode)
    @place_entity = mock_model(Entity)
    @address = mock_model(Address)
    @place_type.stub!(:code_description).and_return("Warm Wading Pool")
    @county.stub!(:code_description).and_return("Beaver")
    @place_entity.stub!(:addresses).and_return([@address])
    @address.stub!(:street_number).and_return("123")
    @address.stub!(:street_name).and_return("West 23 East 99 North")
    @address.stub!(:city).and_return("O-town")
    @address.stub!(:county).and_return(@county)
    @address.stub!(:postal_code).and_return("99999")
    @place.stub!(:entity_id).and_return(66)
    @place.stub!(:entity).and_return(66)
    @place.stub!(:name).and_return("Eastside Waders Super Special Wading Pool")
    @place.stub!(:place_type).and_return(@place_type)
    @place.stub!(:entity).and_return(@place_entity)
  end

  describe 'place auto-complete' do
    
    it 'should be successful' do
      render 'events/_places_search.html.haml', :locals => { :places => [@place]}
      response.should be_success
    end

    it 'should display the place name, type, and address info' do
      render 'events/_places_search.html.haml', :locals => { :places => [@place]}
      response.should have_text(/Eastside Waders Super Special Wading Pool/)
      response.should have_text(/Warm Wading Pool/)
      response.should have_text(/123/)
      response.should have_text(/West 23 East 99 North/)
      response.should have_text(/O-town/)
      response.should have_text(/Beaver/)
      response.should have_text(/99999/)
    end
  end

end

# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
    @place = Factory.build(:place)
    @place_type = Factory.build(:code)
    @county = Factory.build(:external_code)
    @place_entity = Factory.build(:place_entity)
    @canonical_address = Factory.build(:address)
    @place_types.stubs(:code_description).returns("Warm Wading Pool")
    @county.stubs(:code_description).returns("Beaver")
    @place_entity.stubs(:canonical_address).returns(@canonical_address)
    @canonical_address.stubs(:street_number).returns("123")
    @canonical_address.stubs(:street_name).returns("West 23 East 99 North")
    @canonical_address.stubs(:city).returns("O-town")
    @canonical_address.stubs(:county).returns(@county)
    @canonical_address.stubs(:postal_code).returns("99999")
    @place.stubs(:entity_id).returns(66)
    @place.stubs(:entity).returns(66)
    @place.stubs(:name).returns("Eastside Waders Super Special Wading Pool")
    @place.stubs(:place_types).returns([@place_type])
    @place.stubs(:entity).returns(@place_entity)
    @place.stubs(:formatted_place_descriptions).returns(@place_types.code_description)

    @places = [ @place ]
    @places.stubs(:total_pages).returns(1)
  end

  describe 'place auto-complete' do

    it 'should be successful' do
      render 'events/_places_search.html.haml', :locals => { :places => @places}
      response.should be_success
    end

    it 'should display the place name, type, and address info' do
      render 'events/_places_search.html.haml', :locals => { :places => @places}
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

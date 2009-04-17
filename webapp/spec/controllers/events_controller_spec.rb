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

require File.dirname(__FILE__) + '/../spec_helper'

# Many specs are commented out. The mocking exercise is not a small undertaking.
# Perhaps it can be chipped away at.

describe EventsController do
  describe "handling GET /events/auto_complete_for_places_search" do

    before(:each) do
      mock_user
      @place = mock_model(Place)
      Place.stub!(:find).and_return([@place])
    end
  
    def do_post
      post :auto_complete_for_places_search, :place_name => "A"
    end
  
    it "should be successful" do
      do_post
      response.should be_success
    end

    it "should render index template" do
      do_post
      response.should render_template('events/_places_search')
    end
  
    it "should assign the found places for the view" do
      do_post
      assigns[:places].should == [@place]
    end
  end

end

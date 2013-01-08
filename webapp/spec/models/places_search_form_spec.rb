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

require File.dirname(__FILE__) + '/../spec_helper'

describe PlacesSearchForm do

  it "will return true if type is a participation type" do
    PlacesSearchForm.new(:place_type => 'InterestedPlace').includes_participation_type?.should == true
    PlacesSearchForm.new(:place_type => 'H').includes_participation_type?.should == true
  end

  it "will return a hash mapping UI value to participation type" do
    PlacesSearchForm.new(:place_type => 'H').participation_types_by_value['H'].should_not be_nil
  end

end

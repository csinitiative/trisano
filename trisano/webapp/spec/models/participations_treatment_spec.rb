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

describe ParticipationsTreatment do
  before(:each) do
    @pt = ParticipationsTreatment.new
  end

  it "should be valid with nothing populated" do
    @pt.should be_valid
  end
  
  it "should be valid with any treatment text and treatment received y/n" do
    @pt.treatment = "Foot massage"
    @pt.treatment_given_yn_id = 1401
    @pt.should be_valid
  end

  it "should validate the treatment date" do
    @pt.treatment_date = 'not a date'
    @pt.should_not be_valid
  end

end

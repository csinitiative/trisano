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

describe ParticipationsPlace do
  describe 'date of exposure' do
    
    it 'should be valid if nil' do
      pp = ParticipationsPlace.create
      pp.should be_valid
    end

    it 'should accept valid dates' do
      pp = ParticipationsPlace.create(:date_of_exposure => 'August 8, 2008')
      pp.should be_valid
    end

    it 'should not accept invalid dates' do
      pp = ParticipationsPlace.create(:date_of_exposure => 'not valid')
      pp.should_not be_valid
    end
  end

end

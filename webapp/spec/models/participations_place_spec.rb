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

require 'spec_helper'

describe ParticipationsPlace do
  
  describe 'date of exposure' do
    before(:each) do
      @pp = ParticipationsPlace.create
    end
   
    it 'should be valid if nil' do
      @pp.should be_valid
    end

    it 'should accept valid dates' do
      @pp.update_attributes(:date_of_exposure => '2009-08-07')
      @pp.errors.on(:date_of_exposure).should be_nil
    end

    it 'should not accept invalid dates' do
      @pp.update_attributes(:date_of_exposure => 'not valid')
      @pp.errors.on(:date_of_exposure).should == "is not a valid date"
    end

    it 'should be valid for exposure dates in the past' do
      @pp.update_attributes(:date_of_exposure => Date.yesterday)
      @pp.should be_valid
      @pp.errors.on(:date_of_exposure).should be_nil
    end

    it 'should not be valid for exposure dates in the future' do
      @pp.update_attributes(:date_of_exposure => Date.tomorrow)
      @pp.errors.on(:date_of_exposure).should == "must be on or before " + Date.today.to_s
    end
  end

end

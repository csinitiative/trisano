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

describe ParticipationsContact do
  describe 'disposition date' do
    before(:each) do
      @pc = ParticipationsContact.create
    end
   
    it 'should be valid if nil' do
      @pc.should be_valid
    end

    it 'should accept valid dates' do
      @pc.update_attributes(:disposition_date => '2009-08-07')
      @pc.errors.on(:disposition_date).should be_nil
    end

    it 'should not accept invalid dates' do
      @pc.update_attributes(:disposition_date => 'not valid')
      @pc.errors.on(:disposition_date).should == "is not a valid date"
    end

    it 'should be valid for disposition dates in the past' do
      @pc.update_attributes(:disposition_date => Date.yesterday)
      @pc.errors.on(:disposition_date).should be_nil
    end

    it 'should not be valid for disposition dates in the future' do
      @pc.update_attributes(:disposition_date => 1.day.from_now)
      @pc.errors.on(:disposition_date).should == "must be on or before " + (Time.now).strftime("%Y-%m-%d")
    end
    
    it 'should force the requirement of a disposition' do
      @pc.update_attributes(:disposition_date => 7.days.from_now)
      @pc.errors.on(:disposition).should == "is required when a disposition date is present"
      @pc.update_attributes(:disposition => Factory.create(:external_code))
      @pc.errors.on(:disposition).should be_nil
    end
  end

end

# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

describe Code do
  before(:each) do
    @code = Code.new
  end

  it "should not be valid when empty" do
    @code.should_not be_valid
  end

  it "should be valid when populated" do
    @code.code_name = 'test'
    @code.the_code = 'TEST'
    @code.code_description = 'Test Code'
    @code.save!
    @code.should be_valid
  end

  describe 'Jurisdiction place type' do
    fixtures :codes
    it 'should exist' do
      Code.jurisdiction_place_type_id.should_not be_nil
      Code.jurisdiction_place_type.should_not be_nil
    end
  end
end

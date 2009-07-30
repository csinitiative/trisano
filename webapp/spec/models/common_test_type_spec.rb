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

describe CommonTestType do

  describe 'associations' do
    it { should have_many(:disease_common_test_types) }
    it { should have_many(:diseases) }
    it { should have_many(:loinc_codes) }
  end

  describe 'common name' do

    it 'should be unique' do
      CommonTestType.create :common_name => 'Doit'
      lambda {CommonTestType.create! :common_name => 'Doit'}.should raise_error
      CommonTestType.new(:common_name => 'Doit').should_not be_valid
      CommonTestType.new(:common_name => 'Do something else').should be_valid
    end

    it 'should not be null' do
      lambda {CommonTestType.create!}.should raise_error
      CommonTestType.new.should_not be_valid
    end

    it 'should not be longer then 255 chars' do
      CommonTestType.new(:common_name => ('c' * 256)).should_not be_valid
      CommonTestType.new(:common_name => ('c' * 255)).should be_valid
    end

  end

end

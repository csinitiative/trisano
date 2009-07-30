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

describe LoincCode do

  describe 'loinc code' do

    it 'should be unique' do
      LoincCode.create :loinc_code => '999999-9'
      lambda {LoincCode.create! :loinc_code => '999999-9'}.should raise_error
      LoincCode.new(:loinc_code => '999999-9').should_not be_valid
      LoincCode.new(:loinc_code => '888888-8').should be_valid
    end

    it 'should not be null' do
      lambda {LoincCode.create!}.should raise_error
      LoincCode.new.should_not be_valid
    end

    it 'should not be longer then 10 chars' do
      LoincCode.new(:loinc_code => ('c' * 11)).should_not be_valid
      LoincCode.new(:loinc_code => ('c' * 10)).should be_valid
    end

  end

  describe 'test name' do

    it 'should not be longer then 255 chars' do
      LoincCode.new(:loinc_code => '999999-9', :test_name => ('c' * 256)).should_not be_valid
      LoincCode.new(:loinc_code => '999999-9', :test_name => ('c' * 255)).should be_valid
    end

  end

  describe 'associations' do

    it { should belong_to(:common_test_name) }

  end
end

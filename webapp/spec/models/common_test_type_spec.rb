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

  describe '#update_loinc_codes' do

    before do
      @loinc_code = LoincCode.create! :loinc_code => '14375-1', :test_name => 'Nulla felis nibh, aliquet eget, Unspecified'
      @common_test_type = CommonTestType.create! :common_name => 'Nulla felis nibh, aliquet eget.'
    end

    it 'should associate a loinc_code with the test_type' do
      @common_test_type.loinc_codes.should == []
      @common_test_type.update_loinc_codes :add => [@loinc_code]
      @common_test_type.loinc_codes.should == [@loinc_code]
    end

    it 'should accept a list of ids' do
      @common_test_type.loinc_codes.should == []
      @common_test_type.update_loinc_codes :add => [@loinc_code.id.to_s]
      @common_test_type.loinc_codes.should == [@loinc_code]
      lambda{@common_test_type.update_loinc_codes :add => [@loinc_code.id.to_s] }.should_not raise_error
    end

    it 'should delete associations for removed loincs' do
      @common_test_type.update_loinc_codes :add => [@loinc_code]
      @common_test_type.loinc_codes.should == [@loinc_code]
      @common_test_type.update_loinc_codes :remove => [@loinc_code]
      @common_test_type.loinc_codes.should == []
    end

    it 'should delete associations for removed loinc ids' do
      @common_test_type.update_loinc_codes :add => [@loinc_code]
      @common_test_type.loinc_codes.should == [@loinc_code]
      @common_test_type.update_loinc_codes :remove => [@loinc_code.id]
      @common_test_type.loinc_codes.should == []
    end
  end

  describe '#find_unrelated_loincs' do

    before do
      @loinc_code = LoincCode.create! :loinc_code => '14375-1', :test_name => 'Nulla felis nibh, aliquet eget, Unspecified'
      @common_test_type = CommonTestType.create! :common_name => 'Nulla felis nibh, aliquet eget.'
    end

    it 'should find all matches, if none are associated with this instance' do
      @common_test_type.find_unrelated_loincs(:test_name => 'nulla').should == [@loinc_code]
    end

    it 'should return empty array if all matches are already assoc, with this instance' do
      @common_test_type.update_loinc_codes :add => [@loinc_code]
      @common_test_type.find_unrelated_loincs(:test_name => 'nulla').should == []
    end

  end
end

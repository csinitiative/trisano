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

describe CodeName do
  include CodeSpecHelper

  before(:each) do
    @code_name = CodeName.new()
  end

  it "blank code_name should not be valid" do
    @code_name.should_not be_valid
  end

  it "uniqe code_name should be valid" do
    @code_name.code_name = 'test'
    @code_name.should be_valid
    @code_name.save.should be_true
  end

  it "duplicate code_name should result in error" do
    @code_name.code_name = 'test'
    @code_name.should be_valid
    @code_name.save.should be_true

    @code_name2 = CodeName.new()
    @code_name2.code_name = 'test'
    @code_name2.should_not be_valid
    @code_name2.save.should_not be_true
  end

  it "should have a translated description" do
    @code_name.code_name = "eventtype"
    @code_name.description.should == "Event Type"
  end

  describe "drop down selections" do
    before do
      given_external_codes('fakeext', %w(Y N UNK))
      given_codes('fakeint', %w(ALT TLT))
      given_codes('placetype', %w(C J H L))
      @disease = given_disease_specific_external_codes('Dengue', 'fakeext', %w(M))
      @event = Factory.create(:morbidity_event)
      @event.create_disease_event(:disease => @disease)
    end

    it "should return external codes by code name" do
      results = CodeName.drop_down_selections('fakeext')
      results.map(&:the_code).sort.should == %w(N UNK Y)
    end

    it "should return internal codes for drop down selections, by code name" do
      results = CodeName.drop_down_selections('fakeint')
      results.map(&:the_code).sort.should == %w(ALT TLT)
    end

    it "should exclude jurisdictions from drop down selections to prevent accidental jurisdiction creation" do
      results = CodeName.drop_down_selections('placetype')
      results.should_not be_empty
      results.map(&:the_code).include?('J').should be_false
    end

    it "should return disease specific external codes for drop down selections" do
      results = CodeName.drop_down_selections('fakeext', @event)
      results.map(&:the_code).sort.should == %w(M N UNK Y)
    end
  end

end


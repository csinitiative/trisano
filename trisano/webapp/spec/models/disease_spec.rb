# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe Disease do
  before(:each) do
    @disease = Disease.new(:disease_name => "The Pops")
  end

  it "should be valid" do
    @disease.should be_valid
  end

  it "should not be active" do
    @disease.should_not be_active
  end

  it "can be made active" do
    @disease.active = true
    @disease.save.should be_true
    @disease.should be_active
  end

  it 'should have no cdc code' do
    @disease.cdc_code.should be_nil
  end

  it 'can set the cdc code' do
    @disease.cdc_code = '99123'
    @disease.save.should be_true
    @disease.cdc_code.should_not be_nil
  end

  it '#find_active should not return inactive diseases' do
    @disease.save.should be_true
    Disease.find(:all).size.should >= 1
    Disease.find_active(:all).size.should == 0
  end

  it '#find_active should return active diseases' do
    @disease.active = true
    @disease.save.should be_true
    Disease.find_active(:all).size.should == 1
  end
end

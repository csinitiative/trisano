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

describe Address do
  before(:each) do
    @address = Address.new
  end

  it "should be invalid without at least one non-blank attrbute" do
    @address.save
    @address.errors.on(:base).should == "At least one address field must have a value"
  end

  it "should be valid with one non-blank attrbute" do
    @address.street_number = "123"
    @address.should be_valid
  end

  it "should be valid with one or more non-blank attrbutes" do
    @address.street_number = "123"
    @address.street_name = "Main St."
    @address.should be_valid
  end

  it "should return a number and street value" do
    address = Address.new(:street_number => "123",
                          :street_name => "Main")
    address.number_and_street.should == '123 Main'
  end

  it "should return a state name" do
    address = Address.new(:state => ExternalCode.new(:code_description => 'Utah'))
    address.state_name.should == 'Utah'
  end
end

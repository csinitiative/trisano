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

describe Address, '#compact_format' do
  before(:each) do
    @address = Address.create(:street_number => '123', :street_name => 'Sesame Street')
    @state = ExternalCode.new(:the_code => 'NY', :code_description => 'New York')
    @county = ExternalCode.new(:code_description => 'Some County')
  end

  it "should leave off unprovided information" do
    @address.compact_format.should == '123 Sesame Street'
  end

  it "should include unit number if provided" do
    @address.update_attributes(:unit_number => '1A')
    @address.compact_format.should match(/^Unit 1A/)
  end

  it "should include city if provided" do
    @address.update_attributes(:city => 'Anytown')
    @address.compact_format.should match(/Anytown$/)
  end

  it "should include state if provided" do
    @address.update_attributes(:state => @state)
    @address.compact_format.should match(/NY$/)
  end

  it "should include postal code if provided" do
    @address.update_attributes(:postal_code => '00000')
    @address.compact_format.should match(/00000$/)
  end

  it "should format correctly with state and postal code" do
    @address.update_attributes(:state => @state, :postal_code => '00000')
    @address.compact_format.should match(/NY  00000$/)
  end

  it "should format correctly with city and postal code" do
    @address.update_attributes(:city => 'Anytown', :postal_code => '00000')
    @address.compact_format.should match(/Anytown  00000$/)
  end

  it "should format correctly with city, state, and postal code" do
    @address.update_attributes(:state => @state, :city => 'Anytown', :postal_code => '00000')
    @address.compact_format.should match(/Anytown, NY  00000$/)
  end

  it "should format correctly with city and state" do
    @address.update_attributes(:state => @state, :city => 'Anytown')
    @address.compact_format.should match(/Anytown, NY$/)
  end

  it "should include the county when provided" do
    @address.update_attributes(:county => @county)
    @address.compact_format.should match(/Some County$/)
  end

  it "should append 'county' to the county name when it is not part of the name" do
    @county.code_description = 'Some'
    @address.update_attributes(:county => @county)
    @address.compact_format.should match(/Some County$/)
  end
end

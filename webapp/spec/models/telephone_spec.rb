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

describe Telephone do

  it "should not be valid without some component of a phone number" do
    phone = Telephone.new
    phone.should_not be_valid
  end

  it "should produce a simple phone format" do
    phone = Telephone.new(:area_code => '123',
                          :phone_number => '765-4321',
                          :extension => '9')
    phone.simple_phone_number.should == '(123) 765-4321 Ext. 9'
  end

  it "should produce a phone format w/out an area code" do
    phone = Telephone.new(:phone_number => '765-4321',
                          :extension   => '9')
    phone.simple_phone_number.should == '765-4321 Ext. 9'
  end

  it "should produce a phone format w/out an extension" do
    phone = Telephone.new(:area_code => '123',
                          :phone_number => '765-4321')
    phone.simple_phone_number.should == '(123) 765-4321'
  end

  it "should produce a phone format w/ a label" do
    loc_code = external_code!('phone_label', 'Foo', :code_description => 'Foo')
    phone = Telephone.new(:area_code => '123',
                          :phone_number => '765-4321',
                          :entity_location_type => loc_code)
    phone.simple_format.should == 'Foo: (123) 765-4321'
  end

  # TODO: test validations here
  it "should require at leat one field be filled in" do
    phone = Telephone.create
    phone.errors.on(:base).should == "At least one telephone field must have a value"
  end

  it "should validate phone number format" do
    phone = Telephone.create :phone_number => 'blah'
    phone.errors.on(:phone_number).should == "must not be blank and must be 7 digits with an optional dash (e.g.5551212 or 555-1212)"
  end

  it "should validate area code format" do
    phone = Telephone.create :area_code => 1
    phone.errors.on(:area_code).should == 'must be 3 digits'
  end

  it "should validate extension" do
    phone = Telephone.create :extension => '1' * 7
    phone.errors.on(:extension).should == 'must have 1 to 6 digits'
  end

  it "should use phone number" do
    Telephone.new.use?(:phone_number).should be_true
  end

  it "should use extension" do
    Telephone.new.use?(:extension).should be_true
  end

  it "should use area code" do
    Telephone.new.use?(:area_code).should be_true
  end

  it "should not use country code" do
    Telephone.new.use?(:country_code).should_not be_true
  end

  it "should ignore country code in validations" do
    phone = Telephone.create(:phone_number => '1234567', :country_code => '123445')
    phone.errors.on(:country_code).should == nil
  end

  describe "set up for country code" do
    before do
      @telephone_options = {:use_country_code => true, :country_code_format => "+%s", :country_code => '^(\d{1,3})$'}.merge(Telephone.telephone_options)
      Telephone.telephone_options = @telephone_options
      @t = Telephone.create!(:country_code => "356",
                             :area_code => "987",
                             :phone_number => "1234567")
    end

    after { Telephone.telephone_options = nil }

    it "should use country code" do
      @t.use?(:country_code).should be_true
    end

    it "should display the country code" do
      @t.simple_format.should == "+356 (987) 123-4567"
    end

    it "should not show area code" do
      Telephone.telephone_options = @telephone_options.merge('use_area_code' => false)
      @t.simple_format.should == "+356 123-4567"
    end

  end

end

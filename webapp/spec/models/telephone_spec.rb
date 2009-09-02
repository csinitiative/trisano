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

describe Telephone do

  it "should not be valid without some component of a phone number" do
    Telephone.new.should_not be_valid
  end

  it "should produce a simple phone format" do
    phone = Telephone.new(:area_code => '123', 
                          :phone_number => '765-4321',
                          :extension => '9')
    phone.simple_format.should == '(123) 765-4321 Ext. 9'
  end
  
  it "should produce a phone format w/out an area code" do
    phone = Telephone.new(:phone_number => '765-4321',
                          :extension   => '9')
    phone.simple_format.should == '765-4321 Ext. 9'
  end

  it "should produce a phone format w/out an extension" do
    phone = Telephone.new(:area_code => '123',
                          :phone_number => '765-4321')
    phone.simple_format.should == '(123) 765-4321'
  end

  # TODO: test validations here

end

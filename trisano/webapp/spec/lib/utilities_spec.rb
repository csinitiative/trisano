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

describe Utilities do

  describe "the underscore method" do

    it "should strip surrounding whitespace" do
      Utilities::underscore("   abc   ").should == "abc"
    end

    it "should replace internal whitespace with underscores" do
      Utilities::underscore("abc 123   def").should == "abc_123_def"
    end

    it "should remove surrounding whitespace and replace internal whitespace with underscores" do
      Utilities::underscore("   abc 123   def ").should == "abc_123_def"
    end

  end

  describe "the make_queue_name method" do

    it "should strip surrounding whitespace and camelcase" do
      Utilities::make_queue_name("   abc   ").should == "Abc"
    end

    it "should lowercase the string and camelcase" do
      Utilities::make_queue_name("AbC").should == "Abc"
    end

    it "should remove underscores (nee whitespace) and replace with camelcase" do
      Utilities::make_queue_name("   ABC   def ").should == "AbcDef"
    end

  end
end

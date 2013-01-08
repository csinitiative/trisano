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

describe CodeName do

  before(:each) do
    @code_name = CodeName.new
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

    @code_name2 = CodeName.new
    @code_name2.code_name = 'test'
    @code_name2.should_not be_valid
    @code_name2.save.should_not be_true
  end

  it "should have a translated description" do
    @code_name.code_name = "eventtype"
    @code_name.description.should == "Event Type"
  end

end


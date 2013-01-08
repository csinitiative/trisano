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

describe ExportConversionValue do
  before(:each) do
    @xcv = ExportConversionValue.new
  end

  it "should require a value_to" do
    @xcv.sort_order = 1

    @xcv.should_not be_valid
    @xcv.value_to = "info"
    @xcv.should be_valid
  end

  it "should force sort_order to be a number" do
    @xcv.value_to = "info"

    @xcv.sort_order = "Hi"
    @xcv.should_not be_valid
    @xcv.sort_order = 1
    @xcv.should be_valid
  end

end

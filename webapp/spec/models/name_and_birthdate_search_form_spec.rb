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

describe NameAndBirthdateSearchForm do

  it "should report errors on invalid dates" do
    form = NameAndBirthdateSearchForm.new(:birth_date => '1947-10-')
    form.should_not be_valid
    form.errors.on(:birth_date).should == 'is not a valid date'
  end

  it "should report errors on two digit years" do
    form = NameAndBirthdateSearchForm.new(:birth_date => 'January 1, 85')
    form.should_not be_valid
    form.errors.on(:birth_date).should == "is not a valid date"
  end
end

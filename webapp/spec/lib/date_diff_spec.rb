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

describe DateDiff do

  it "returns no difference if dates are equal" do
    result = DateDiff.new(Date.today, Date.today).calculate
    result.days.should == 0
    result.months.should == 0
    result.years.should == 0
  end

  it "returns days if dates are the same except for month days" do
    result = DateDiff.new(Date.civil(2009, 8, 23), Date.civil(2009, 8, 3)).calculate
    result.days.should == 20
    result.months.should == 0
    result.years.should == 0
  end

  it "returns days if dates are less then a month apart" do
    result = DateDiff.new(Date.civil(2009, 8, 3), Date.civil(2009, 7, 20)).calculate
    result.days.should == 14
    result.months.should == 0
    result.years.should == 0
  end

  it "returns months and days if dates are more then a month apart" do
    result = DateDiff.new(Date.civil(2009, 8, 3), Date.civil(2009, 7, 1)).calculate
    result.days.should == 2
    result.months.should == 1
    result.years.should == 0
  end

  it "returns days remainder based on number of days in the specific month" do
    result = DateDiff.new(Date.civil(2009, 7, 3), Date.civil(2009, 6, 1)).calculate
    result.days.should == 2
    result.months.should == 1
    result.years.should == 0
  end

  it "calculates months based on the number of days in each month" do
    result = DateDiff.new(Date.civil(2009, 7, 3), Date.civil(2009, 2, 1)).calculate
    result.days.should == 2
    result.months.should == 5
    result.years.should == 0
  end

  it "calculates the difference in years" do
    result = DateDiff.new(Date.civil(2010, 3, 1), Date.civil(2009, 3, 1)).calculate
    result.days.should == 0
    result.months.should == 0
    result.years.should == 1
  end

  it "returns months count, even if when the months span years" do
    result = DateDiff.new(Date.civil(2010, 3, 1), Date.civil(2009, 8, 1)).calculate
    result.days.should == 0
    result.months.should == 7
    result.years.should == 0
  end

  it "calculates Febuary correctly" do
    result = DateDiff.new(Date.civil(2010, 3, 14), Date.civil(2009, 3, 16)).calculate
    result.days.should == 26
    result.months.should == 11
    result.years.should == 0
  end

  it "calculates Febuary correctly in leap years" do
    result = DateDiff.new(Date.civil(2008, 3, 14), Date.civil(2007, 3, 16)).calculate
    result.days.should == 27
    result.months.should == 11
    result.years.should == 0
  end

  it "should make sure to borrow enough days to return a positive number of days" do
    result = DateDiff.new(Date.civil(2010, 2, 1), Date.civil(2009, 3, 31)).calculate
    result.days.should == 1
    result.months.should == 10
    result.years.should == 0
  end

  it "should handle carrying months across years" do
    result = DateDiff.new(Date.civil(2010, 1, 1), Date.civil(2008, 12, 31)).calculate
    result.days.should == 1
    result.months.should == 0
    result.years.should == 1
  end
end

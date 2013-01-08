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

describe AgeInfo, 'age at onset' do

  describe "is less then a month" do
    it "returns age in days" do
      age_info = AgeInfo.create_from_dates(Date.civil(2010, 3, 2), Date.civil(2010, 3, 21))
      age_info.age_at_onset.should == 19
      age_info.age_type.code_description.should == 'days'
    end

    it "returns age in day if dates span months" do
      age_info = AgeInfo.create_from_dates(Date.civil(2010, 7, 16), Date.civil(2010, 8, 14))
      age_info.age_at_onset.should == 29
      age_info.age_type.code_description.should == 'days'
    end
  end

  describe "is less then a year" do
    it "returns months" do
      age_info = AgeInfo.create_from_dates(Date.civil(2010, 7, 13), Date.civil(2010, 8, 14))
      age_info.age_at_onset.should == 1
      age_info.age_type.code_description.should == 'months'
    end

    it "returns months and never rounds up to a year" do
      age_info = AgeInfo.create_from_dates(Date.civil(2009, 8, 15), Date.civil(2010, 8, 14))
      age_info.age_at_onset.should == 11
      age_info.age_type.code_description.should == 'months'
    end

    it "returns months and never rounds up, even in a leap year" do
      age_info = AgeInfo.create_from_dates(Date.civil(2007, 3, 1), Date.civil(2008, 2, 29))
      age_info.age_at_onset.should == 11
      age_info.age_type.code_description.should == 'months'
    end
  end

  describe "is a year or greater" do
    it "returns years" do
      age_info = AgeInfo.create_from_dates(Date.civil(2009, 3, 1), Date.civil(2010, 3, 1))
      age_info.age_at_onset.should == 1
      age_info.age_type.code_description.should == 'years'
    end

    it "returns years and never rounds up" do
      age_info = AgeInfo.create_from_dates(Date.civil(2008, 3, 1), Date.civil(2010, 2, 28))
      age_info.age_at_onset.should == 1
      age_info.age_type.code_description.should == 'years'
    end
  end

end

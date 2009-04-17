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

describe AgeInfo do

  it 'should store ages < 29 days as days' do
    age_info = AgeInfo.create_from_dates(Date.today - 1, Date.today)
    age_info.age_at_onset.should == 1
    age_info.age_type.code_description.should == "days"
    age_info.age_type.id.should == 2300
    age_info.age_type.code_name.should == 'age_type'

    age_info = AgeInfo.create_from_dates(Date.today - 27, Date.today)
    age_info.age_at_onset.should == 27
    age_info.age_type.code_description.should == "days"
  end
    
  it 'should store ages < 8 weeks as weeks' do
    age_info = AgeInfo.create_from_dates(Date.today - 28, Date.today)
    age_info.age_at_onset.should == 4
    age_info.age_type.code_description.should == "weeks"
    
    age_info = AgeInfo.create_from_dates(Date.today - 7*7, Date.today)
    age_info.age_at_onset.should == 7
    age_info.age_type.code_description.should == "weeks"
  end

  it 'should store ages between 8 weeks and < 12 months as months' do
    age_info = AgeInfo.create_from_dates(Date.today - 7*8, Date.today)
    age_info.age_at_onset.should == 2
    age_info.age_type.code_description.should == 'months'

    age_info = AgeInfo.create_from_dates(Date.today.months_ago(11), Date.today)
    age_info.age_at_onset.should == 11
    age_info.age_type.code_description.should == 'months'
  end

  it 'should store ages > 11 months as years' do
    age_info = AgeInfo.create_from_dates(Date.today.years_ago(1), Date.today)
    age_info.age_at_onset.should == 1
    age_info.age_type.code_description == 'years'

    age_info = AgeInfo.create_from_dates(Date.today.years_ago(14), Date.today)
    age_info.age_at_onset.should == 14
    age_info.age_type.code_description == 'years'
  end

end

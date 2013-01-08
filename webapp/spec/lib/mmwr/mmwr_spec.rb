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

require File.dirname(__FILE__) + '/../../spec_helper'
require 'date'

describe Mmwr do

  before(:each) do
    t = Time.now
    @now = Date.new(t.year, t.month, t.day)
  end

  it "should handle bogus constructor args" do
    lambda {Mmwr.new(String.new)}.should raise_error(ArgumentError, "Mmwr initialize only handles Hash or Date")
  end

  it "should calculate week and year for empty constructor" do
    mmwr = Mmwr.new
    mmwr.mmwr_week
    mmwr.mmwr_year
  end

  describe "epi date used" do

    it "should be onsetdate if onset date is available" do
      epi_dates = { :onsetdate => @now}
      mmwr = Mmwr.new(epi_dates)
      mmwr.epi_date_used.should == :onsetdate
    end

    it "should favor onset date over other epi dates" do
      epi_dates = { :onsetdate => @now, :diagnosisdate => @now }
      mmwr = Mmwr.new(epi_dates)
      mmwr.epi_date_used.should == :onsetdate
    end

    it "should be nil if no dates are available" do
      mmwr = Mmwr.new
      mmwr.epi_date_used.should be_nil
    end

    it "should select earliest labe result date of first reported date" do
      epi_dates = { :firstreportdate => @now, :labresultdate => @now }
      mmwr = Mmwr.new(epi_dates)
      mmwr.epi_date_used.should == :labresultdate
    end

    it "should select disagnosis date overt earliest lab result date" do
      epi_dates = { :diagnosisdate => @now, :labresultdate => @now }
      mmwr = Mmwr.new(epi_dates)
      mmwr.epi_date_used.should == :diagnosisdate
    end

    it "should select lab result date if disagnosis date is not available" do
      epi_dates = { :diagnosisdate => nil, :labresultdate => @now }
      mmwr = Mmwr.new(epi_dates)
      mmwr.epi_date_used.should == :labresultdate
    end

    it "should not fail with all nil dates" do
      epi_dates = { :onsetdate => nil,
        :diagnosisdate => nil,
        :labresultdate => nil,
        :firstreportdate => nil }
      mmwr = Mmwr.new(epi_dates)
      mmwr.mmwr_week
      mmwr.mmwr_year
    end

    it "should be firstreportdate" do
      epi_dates = { :firstreportdate => @now }
      mmwr = Mmwr.new(epi_dates)
      mmwr.epi_date_used.should == :firstreportdate
    end

    it "is the date the event is create if that date is present and no other valid dates are available" do
      mmwr = Mmwr.new(:event_created_date => @now)
      mmwr.epi_date_used.should == :event_created_date
    end

    it "should be nil if date is given explicitly" do
      mmwr = Mmwr.new(@now)
      mmwr.epi_date_used.should be_nil
    end
  end

  it "should be 1 for Jan 01 2008" do
    epi_dates = { :onsetdate => Date.new(2008, 1, 1) }
    mmwr = Mmwr.new(epi_dates)
    mmwr.mmwr_week.should == 1
  end

  it "should be 2 for Jan 06 2008" do
    epi_dates = { :onsetdate => Date.new(2008, 1, 6) }
    mmwr = Mmwr.new(epi_dates)
    mmwr.mmwr_week.should == 2
  end

  it "should be 53 for Dec 31 2008" do
    epi_dates = { :onsetdate => Date.new(2008, 12, 31) }
    mmwr = Mmwr.new(epi_dates)
    mmwr.mmwr_week.should == 53
  end

  it "should be year 2008 week 53 for Jan 01 2009" do
    epi_dates = { :onsetdate => Date.new(2009, 1, 1) }
    mmwr = Mmwr.new(epi_dates)
    mmwr.mmwr_week.should == 53
    mmwr.mmwr_year.should == 2008
  end

  it "should be year 2009 week 53 for Dec 26 2009" do
    epi_dates = { :onsetdate => Date.new(2009, 12, 26) }
    mmwr = Mmwr.new(epi_dates)
    mmwr.mmwr_week.should == 51
    mmwr.mmwr_year.should == 2009
  end

  it "should be year 2009 week 52 for Jan 02 2010" do
    epi_dates = { :onsetdate => Date.new(2009, 12, 26) }
    mmwr = Mmwr.new(epi_dates)
    mmwr.mmwr_week.should == 51
    mmwr.mmwr_year.should == 2009
  end

  it "should be week 27 for Jul 7 2009" do
    Mmwr.new(DateTime.new(2009, 7, 11)).mmwr_week.should == 27
  end

  it "should be week 10 for March 13 2009" do
    Mmwr.new(DateTime.new(2009, 3, 13)).mmwr_week.should == 10
  end

  it "should be week 1 for Jan 9 2010" do
    Mmwr.new(DateTime.new(2010, 1, 9)).mmwr_week.should == 1
  end

  it "should be week 52 for Jan 1 2011" do
    Mmwr.new(DateTime.new(2011, 1, 1)).mmwr_week.should == 52
  end

  it "should be week 39 for Sep 29 2006" do
    Mmwr.new(DateTime.new(2006, 9, 29)).mmwr_week.should == 39
  end

  it "should be week 1 for Jan 7 2006" do
    Mmwr.new(Date.new(2006, 1, 07)).mmwr_week.should == 1
  end

  it "should be week 52 for Dec 30 2006" do
    Mmwr.new(Date.new(2006, 12, 30)).mmwr_week.should == 52
  end

  it "should be week 1 for Jan 5 2007" do
    Mmwr.new(Date.new(2007, 1, 05)).mmwr_week.should == 1
  end

  it "should be year 2008, week 7 for Feb 16, 2008" do
    Mmwr.new(Date.new(2008, 2, 16)).mmwr_week.should == 7
  end

  it 'should be able to subtract, like date math' do
    (Mmwr.new(Date.new(2008, 2, 16)) - 1.week).mmwr_week.should == 6
  end

  it 'should be able to add like date math' do
    (Mmwr.new(Date.new(2008, 2, 16)) + 1.week).mmwr_week.should == 8
  end

  it 'should return a valid mmwr object, given an integer representing an mmwr week' do
    Mmwr.week(13, :for_year => 2009).mmwr_week_range.start_date.should == DateTime.new(2009, 3, 29)
  end

  describe 'comparison (<=>)' do
    it 'should return 0 if both mmwr vweek and year are equal' do
      (Mmwr.week(1) <=> Mmwr.week(1)).should == 0
    end

    it 'should return comparison value of years if mmwr years are differnt' do
      (Mmwr.week(14, :for_year => 2008) <=> Mmwr.week(2, :for_year => 2009)).should == -1
    end

    it 'should return comparison value of weeks if years are equal' do
      (Mmwr.week(14) <=> Mmwr.week(2)).should == 1
    end
  end

  describe '#succ' do
    it 'should increment return the next mmwr week' do
      mmwr = Mmwr.week(14, :for_year => 2009).succ
      mmwr.mmwr_week.should == 15
      mmwr.mmwr_year.should == 2009
    end

    it 'should wrap to first week of next year' do
      mmwr = Mmwr.week(52, :for_year => 2009).succ
      mmwr.mmwr_week.should == 1
      mmwr.mmwr_year.should == 2010
    end

    it 'should return next mmwr week, even in 2010' do
      mmwr = Mmwr.week(1, :for_year => 2010).succ
      mmwr.mmwr_week.should == 2
      mmwr.mmwr_year.should == 2010
    end

  end
end

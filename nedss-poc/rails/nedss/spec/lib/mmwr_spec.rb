require File.dirname(__FILE__) + '/../spec_helper'
require 'date'

describe Mmwr do
  before do

  end

  it "should be onsetdate" do
    epi_dates = { :onsetdate => DateTime.now}
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :onsetdate
  end

  it "should be onsetdate" do
    epi_dates = { :onsetdate => DateTime.now, :diagnosisdate => DateTime.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :onsetdate
  end

  it "should be labresultdate" do
    epi_dates = { :firstreportdate => DateTime.now, :labresultdate => DateTime.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :labresultdate
  end

  it "should be diagnosisdate" do
    epi_dates = { :diagnosisdate => DateTime.now, :labresultdate => DateTime.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :diagnosisdate
  end

  it "should be firstreportdate" do
    epi_dates = { :firstreportdate => DateTime.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :firstreportdate
  end
  
  it "should be first_week" do
    epi_dates = { :onsetdate => DateTime.new(2008, 1, 1) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.year_first_mmwr_week.should == :first_week
  end
  
  it "should be :second_week" do
    epi_dates = { :onsetdate => DateTime.new(2009, 1, 1) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.year_first_mmwr_week.should == :second_week
  end      

  it "should be 1 for Jan 01 2008" do 
    epi_dates = { :onsetdate => DateTime.new(2008, 1, 1) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.mmwr_week.should == 1
  end

  it "should be 2 for Jan 06 2008" do
    epi_dates = { :onsetdate => DateTime.new(2008, 1, 6) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.mmwr_week.should == 2
  end

  it "should be 53 for Dec 31 2008" do 
    epi_dates = { :onsetdate => DateTime.new(2008, 12, 31) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.mmwr_week.should == 53
  end

  it "should be year 2008 week 53 for Jan 01 2009" do     
    epi_dates = { :onsetdate => DateTime.new(2009, 1, 1) }
    @mmwr = Mmwr.new(epi_dates)
    mmwr_week_range = @mmwr.mmwr_week_range
    year = mmwr_week_range.mmwr_year.to_i
    year.should == 2008
    week = mmwr_week_range.mmwr_week.to_i
    week.should == 53
  end
end


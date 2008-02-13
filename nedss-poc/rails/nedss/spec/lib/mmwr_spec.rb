require File.dirname(__FILE__) + '/../spec_helper'
require 'date'

describe Mmwr do
  before do

  end
  
  it "should handle bogus constructor args" do
    lambda {Mmwr.new(String.new)}.should raise_error(ArgumentError, "Mmwr initialize only handles Hash or DateTime")
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
  
  it "should be unknown for a provided DateTime" do
    @mmwr = Mmwr.new(DateTime.new)
    @mmwr.epi_date_used.should == :unknown
  end  
  
  it "should be unknown for no-arg constructor" do
    @mmwr = Mmwr.new
    @mmwr.epi_date_used.should == :unknown
  end    
  
  it "should be :first_week" do
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
  
  it "should be year 2009 week 53 for Dec 26 2009" do     
    epi_dates = { :onsetdate => DateTime.new(2009, 12, 26) }
    @mmwr = Mmwr.new(epi_dates)
    mmwr_week_range = @mmwr.mmwr_week_range
    year = mmwr_week_range.mmwr_year.to_i
    year.should == 2009
    week = mmwr_week_range.mmwr_week.to_i
    week.should == 51
  end
  
  it "should be year 2009 week 52 for Jan 02 2010" do     
    epi_dates = { :onsetdate => DateTime.new(2009, 12, 26) }
    @mmwr = Mmwr.new(epi_dates)
    mmwr_week_range = @mmwr.mmwr_week_range
    year = mmwr_week_range.mmwr_year.to_i
    year.should == 2009
    week = mmwr_week_range.mmwr_week.to_i
    week.should == 51
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
    Mmwr.new(DateTime.new(2006, 1, 07)).mmwr_week.should == 1
  end    
  
  it "should be week 52 for Dec 30 2006" do
    Mmwr.new(DateTime.new(2006, 12, 30)).mmwr_week.should == 52
  end     
  
  it "should be week 1 for Jan 5 2007" do
    Mmwr.new(DateTime.new(2007, 1, 05)).mmwr_week.should == 1
  end       
  
end


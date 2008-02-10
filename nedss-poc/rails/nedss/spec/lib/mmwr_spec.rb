require File.dirname(__FILE__) + '/../spec_helper'
require 'date'

describe Mmwr do
  before do

  end

  it "should be 1" do
    epi_dates = { :onsetdate => DateTime.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.calculation.should == 1
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

  it "should be 1 for Jan 01 2008" do 
    #pending("get mmwr calculation working for Jan 01 2008")
    epi_dates = { :onsetdate => DateTime.new(2008, 1, 1) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.calculation.should == 1
  end

  it "should be 2 for Jan 06 2008" do
    pending("get mmwr calculation working for Jan 06 2008")
    epi_dates = { :onsetdate => DateTime.new(2008, 1, 6) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.calculation.should == 2
  end

  it "should be 52 for Dec 31 2008" do 
    pending("get mmwr calculation working for Dec 31 2008")
    epi_dates = { :onsetdate => DateTime.new(2008, 12, 31) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.calculation.should == 52
  end

  it "should be 52 for Jan 01 2009" do 
    pending("get mmwr calculation working for Jan 01 2009")
    epi_dates = { :onsetdate => DateTime.new(2009, 1, 1) }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.calculation.should == 52
  end
end


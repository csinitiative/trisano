require File.dirname(__FILE__) + '/../spec_helper'
require 'date'

describe Mmwr do
  before do

  end

  it "should be 1" do
    epi_dates = { :onsetdate => Time.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.calculation.should == 1
  end

  it "should be onsetdate" do
    epi_dates = { :onsetdate => Time.now}
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :onsetdate
  end

  it "should be onsetdate not diagnosisdate" do
    epi_dates = { :onsetdate => Time.now, :diagnosisdate => Time.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :onsetdate
  end

  it "should be onsetdate" do
    epi_dates = { :onsetdate => Time.now, :diagnosisdate => Time.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :onsetdate
  end

  it "should be diagnosisdate" do
    epi_dates = { :diagnosisdate => Time.now, :labresultdate => Time.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :diagnosisdate
  end

  it "should be firstreportdate" do
    epi_dates = { :firstreportdate => Time.now }
    @mmwr = Mmwr.new(epi_dates)
    @mmwr.epi_date_used.should == :firstreportdate
  end

end


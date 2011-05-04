require 'spec_helper'

describe DiseaseEvent do

  before do
    @event = Factory.build :morbidity_event
    @event.attributes = {
      :disease_event_attributes => {
        :date_diagnosed => Date.yesterday
      }
    }
    @de = @event.disease_event
  end

  it "should not be associated w/ more then one event" do
    @event = Factory :morbidity_event_with_disease
    @disease_event = DiseaseEvent.new :event => @event
    @disease_event.should_not be_valid
  end

  describe "onset date" do
    it "is a valid date format" do
      @de.disease_onset_date = 'not a date string'
      @de.should_not be_valid
      @de.errors.on(:disease_onset_date).should_not be_nil
    end
  end

  describe "date diagnosed" do
    it "is valid if it is after the onset date" do
      @de.attributes = { :disease_onset_date => Date.yesterday, :date_diagnosed => Date.today }
      @de.should be_valid
      @de.errors.on(:date_diagnosed).should be_nil
    end

    it "is invalid if it is before the onset date" do
      @de.attributes = { :disease_onset_date => Date.today, :date_diagnosed => Date.yesterday }
      @de.should_not be_valid
      @de.errors.on(:date_diagnosed).should == "must be on or after " + Date.today.to_s
    end

    it "is valid if if occurs in the past" do
      @event.disease_event.should be_valid
    end

    it "is not valid if it occurs in the future" do
      @de.update_attributes(:date_diagnosed => Date.tomorrow)
      @de.errors.on(:date_diagnosed).should == "must be on or before " + Date.today.to_s
    end
  end

end

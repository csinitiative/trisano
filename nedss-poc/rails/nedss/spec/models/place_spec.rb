require File.dirname(__FILE__) + '/../spec_helper'

describe Place do

  fixtures :places

  before(:each) do
    @place = Place.new
  end

  describe "when instantiatied" do
    
    it "should be invalid without a name" do
      @place.should_not be_valid
    end

    it "should be valid with a name" do
      @place.name = "whatever"
      @place.should be_valid
    end
  end

  describe "the build_place class method" do
    it "should create a Place and set place_type" do
      p = Place.build_place(:lab)
      p.place_type.should eql(codes(:place_type_lab))
    end

    it "should thrown an exception for illegal place types" do
      pending "Implement this."
    end
  end

  # The following tests are for basic activerecord functionality that would not ordinarily be tested.
  # They are here in anticipation of acts_as_auditable

  describe "when created and retrieved" do

    before(:each) do
      @place.name = "Abbott Labs"
      @place.short_name = "Abbott"
      @place.place_type = codes(:place_type_lab)
    end

    it "should add a new row" do
      lambda { @place.save }.should change { Place.count }.by(1)
    end

    it "should return what was just created" do
      @place.save
      place = Place.find_by_name("Abbott Labs")
      place.should_not be_nil
      place.name.should == "Abbott Labs"
      place.short_name.should == "Abbott"
      place.place_type.should eql(codes(:place_type_lab))
    end
  end

  describe "when updated and retrieved" do

    before(:each) do
      @place.name = "Abbott Labs"
      @place.short_name = "Abbott"
      @place.place_type = codes(:place_type_lab)
      @place.save

      @place = Place.find_by_name("Abbott Labs")
      @place.short_name = "AL"
      @place.save

      @places = Place.find_all_by_name("Abbott Labs")
      @place = @places.first
    end

    it "should return just one row" do
      @places.length.should == 1
    end

    it "should return what was just updated" do
      @place.short_name.should == "AL"
    end

    it "should maintain non-updated values" do
      @place.name.should == "Abbott Labs"
      @place.place_type.should eql(codes(:place_type_lab))
    end
  end

  describe "additional tests" do
    it "should include tests for helper methods that return hospitals, jurisidictions, etc." do
      pending
    end
  end
end


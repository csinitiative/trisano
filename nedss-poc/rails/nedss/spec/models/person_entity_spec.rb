require File.dirname(__FILE__) + '/../spec_helper'

describe PersonEntity do
  before(:each) do
    @entity = PersonEntity.new
  end

  describe "without associated person" do
    it "should be valid" do
      @entity.should be_valid
    end
  end

  describe "with associated person" do
    before(:each) do
      @entity.people << Person.new 
    end

    describe "where person is not valid" do
      it "should not save" do
        #@person has no last_name and thus is not valid
        @entity.save.should be_false
      end
    end

    describe "where person is valid" do
      it "should save without error" do
        @entity.people.last.last_name = "Lacey"
        @entity.save.should be_true
      end
    end
  end
end

describe PersonEntity, "with people fixture loaded" do
  set_fixture_class :entities => PersonEntity
  fixtures :entities, :people

  it "should have two records" do
    PersonEntity.should have(2).records
  end

  describe "and a single instance of Grocuho Marx" do

    it "should have a total of one person" do
      entities(:Groucho).should have(1).people
    end

    it "should have one current person named groucho" do
      entities(:Groucho).current.first_name.should eql("Groucho")
    end
  end

  describe "and multiple instances of Phil Silvers" do

    it "should have two people altogether" do
      entities(:Silvers).should have(2).people
    end

    it "should have one current person named Phil" do
      entities(:Silvers).current.first_name.should eql("Phil")
    end
  end
end

describe PersonEntity, "with location fixtures loaded" do
  set_fixture_class :entities => PersonEntity
  fixtures :entities, :entities_locations, :locations

  it "should find current locations with type and primary attributes" do
    worked = 0
    entities(:Silvers).current_locations.each do |loc|
      worked = worked + 1 if loc.primary?
      worked = worked + 1 if loc.type == "Work"
    end
    worked.should == 2
  end
end

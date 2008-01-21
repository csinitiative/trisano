require File.dirname(__FILE__) + '/../spec_helper'

describe Entity do
  before(:each) do
    @entity = Entity.new
  end

  describe "without associated person" do
    it "should be valid" do
      @entity.should be_valid
    end
  end

  describe "with associated person" do
    before(:each) do
      @entity.person = Person.new 
    end

    describe "where person is not valid" do
      it "should not save" do
        #@person has not last_name and thus is not valid
        @entity.save.should be_false
      end
    end

    describe "where person is valid" do
      it "should save without error" do
        @entity.person.last_name = "Lacey"
        @entity.save.should be_true
      end
    end
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe "Searching by name and birthdate" do

  describe HumanEvent do
    it "should have a validate_bdate method" do
      HumanEvent.respond_to?(:validate_bdate).should be_true
    end
  end

end

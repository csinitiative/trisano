require 'spec_helper'

describe 'Date validations in english' do
  before :all do
    I18n.locale = :en
  end

  after :all do
    I18n.locale = :en
  end

  it "should recognize September as a month" do
    ValidatesTimeliness::Formats.parse('September 8, 1993', :date).should == [1993, 9, 8, 0, 0, 0, 0]
  end

end

require File.expand_path(File.dirname(__FILE__) +  '/../../../../spec/spec_helper')

describe 'Date validations in spanish' do
  before :all do
    I18n.locale = :es
  end

  after :all do
    I18n.locale = :en
  end

  it "should recognize Septiembre as a month" do
    ValidatesTimeliness::Formats.parse('Septiembre 8, 1993', :date).should == [1993, 9, 8, 0, 0, 0, 0]
  end

end

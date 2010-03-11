require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe CoreField, 'in test locale' do
  before :all do
    CoreField.delete_all  # There's been fixutures spotted around these parts.
  end

  after :all do
    Fixtures.reset_cache
  end

  before :each do
    @core_field = CoreField.create(:key => 'morbidity_event[test_field]', :event_type => 'morbidity_event')
  end

  after { I18n.locale = :en }

  it "should pull test translations for name" do
    I18n.locale = :test
    cf = CoreField.create!(:key => 'morbidity_event[places]', :event_type => 'morbidity_event')
    cf.name.should == 'xPlaces'
  end

end

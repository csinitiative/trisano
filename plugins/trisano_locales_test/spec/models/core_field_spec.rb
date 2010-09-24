require 'spec_helper'

describe CoreField, 'in test locale' do
  before :all do
    CoreField.delete_all  # There's been fixutures spotted around these parts.
  end

  after :all do
    Fixtures.reset_cache
  end

  before :each do
    @core_field = Factory.create(:cmr_core_field, :key => 'morbidity_event[test_field]')
  end

  after { I18n.locale = :en }

  it "should pull test translations for name" do
    I18n.locale = :test
    cf = Factory.create(:cmr_core_field, :key => 'morbidity_event[places]')
    cf.name.should == 'xPlaces'
  end

end

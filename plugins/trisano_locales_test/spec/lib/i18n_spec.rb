require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe I18n do

  before { @restore_default = I18n.default_locale }
  after  { I18n.default_locale_without_db = @restore_default }

  it "default_locale should return what is in the database" do
    dl = DefaultLocale.new
    dl.short_name = :test
    dl.save!
    I18n.default_locale.should == :test
  end

end

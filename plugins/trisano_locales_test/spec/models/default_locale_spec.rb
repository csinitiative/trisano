require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe DefaultLocale do

  before { @restore = I18n.default_locale }
  after  { I18n.default_locale_without_db = @restore }

  it "should be valid without a user" do
    DefaultLocale.create.errors.on(:user_id).should == nil
  end

  it "should not be valid without a short name" do
    DefaultLocale.create.errors.on(:short_name).should == "can't be blank"
  end

  it "updates are not valid if locale is not available" do
    dl = DefaultLocale.new
    dl.update_locale(:bogus).should_not be_true
    dl.errors.on(:short_name).should == "'bogus' is not a supported locale"
  end

  it "current should return latest update" do
    DefaultLocale.new.update_locale(:en)
    DefaultLocale.current.to_sym.should == :en
    DefaultLocale.current.update_locale(:test)
    DefaultLocale.current.to_sym.should == :test
  end

  describe "DefaultLocale#current with no stored locale" do
    before { DefaultLocale.delete_all }

    after :all do
      Fixtures.reset_cache
    end

    it "should be nil" do
      default_locale = DefaultLocale.current.should == nil
    end
  end

  describe "with a stored locale" do
    fixtures :users

    before do
      DefaultLocale.delete_all
      dl = DefaultLocale.new
      dl.update_locale(:test, users(:default_user))
      dl.update_attribute(:created_at, Date.yesterday)
    end

    after :all do
      Fixtures.reset_cache
    end

    after { I18n.default_locale_without_db = :en }

    it "current should return stored default locale" do
      default_locale = DefaultLocale.current
      default_locale.short_name.should == "test"
      default_locale.locale_name.should == "Test"
      default_locale.created_at.to_date.should == Date.yesterday
      default_locale.user.should_not == nil
    end
  end

  describe "locale triggers" do

    it "default_locale= should trigger updates to database" do
      I18n.default_locale = :test
      DefaultLocale.current.to_sym.should == :test
      I18n.default_locale = :en
      DefaultLocale.current.to_sym.should == :en
    end

    it "default_locale should be updated when database changes" do
      DefaultLocale.new.update_locale(:test)
      I18n.default_locale.should == :test
      DefaultLocale.current.update_locale(:en)
      I18n.default_locale.should == :en
    end

    it "default_locale= should not change value if unsupported locale" do
      previous = I18n.default_locale
      I18n.default_locale = :bogus
      I18n.default_locale.should == previous
    end
  end

end

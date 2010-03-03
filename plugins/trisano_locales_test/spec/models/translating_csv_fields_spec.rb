require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

describe CsvField, "long names" do

  before do
    @csv_field = Factory.create :csv_field
    @csv_field.update_attributes!(:long_name => 'sample_long', :short_name => 'smp_shrt')
    @csv_field.csv_field_translations.build(:locale => 'test', :long_name => 'test_sample_long', :short_name => 'tst_shrt').save!
  end

  it "should return default long_name locale text" do
    @csv_field.long_name.should == 'sample_long'
  end

  it "should return default short_name locale text" do
    @csv_field.short_name.should == 'smp_shrt'
  end

  describe "in test locale" do
    before { I18n.locale = :test }
    after  { I18n.locale = :en   }

    it "should return :test locale long text" do
      @csv_field.reload
      @csv_field.long_name.should == 'test_sample_long'
    end

    it "should return :test locale short text" do
      @csv_field.reload
      @csv_field.short_name.should == 'tst_shrt'
    end
  end

end

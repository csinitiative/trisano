require File.expand_path(File.dirname(__FILE__) + '/../../../../../spec/spec_helper')

def translation_spec(factory)
  describe "#{factory.to_s.humanize} translations" do

    before do
      @code = Factory.create factory
      @code.update_attributes!(:code_description => 'sample code')
      @code.code_translations.build(:locale => 'test', :code_description => 'test sample code').save!
    end

    it_should_behave_like "code description translations"
  end
end

def translation_class(code)
  eval("#{code.class.name}Translation")
end

shared_examples_for 'code description translations' do

  it "should delete translation table entries when code is deleted" do
    lambda do
      @code.destroy
    end.should change(translation_class(@code), :count).by(-2)
  end

  describe "in default locale" do
    before { @code.reload }

    it "should return code_descriptions in english" do
      @code.code_description.should == 'sample code'
    end
  end

  describe "in :test locale" do
    before do
      I18n.locale = :test
      @code.reload
    end

    after { I18n.locale = :en }

    it "should return a code_descriptions from the test locale" do
      @code.code_description.should == 'test sample code'
    end
  end

  describe "associations" do
    it 'should have a translations table association' do
      @code.should have_many(:code_translations)
    end
  end

  describe "and a truncated translations table" do
    before do
      translation_class(@code).delete_all
    end

    after :all do
      Fixtures.reset_cache
    end

    it "should have a nil description" do
      @code.class.find(@code.id).code_description.should == nil
    end
  end

  describe "custom selects" do
    it "should not replace select fields that are already explicit" do
      table_name = @code.class.table_name
      lambda do
        @code.class.find(
          :first,
          :select => "#{table_name}.id, #{table_name}.code_description",
          :conditions => ["the_code = ?", @code.the_code])
      end.should_not raise_error
    end
  end

end

translation_spec :code
translation_spec :external_code

describe Code, 'translated ordering in an association' do
  before do
    @place_type1 = Factory.create(:place_type, :code_description => 'one')
    @place_type1.code_translations.build(:locale => 'test', :code_description => 'Zed')
    @place_type1.save!

    @place_type2 = Factory.create(:place_type, :code_description => 'two')
    @place_type2.code_translations.build(:locale => 'test', :code_description => 'Dead')
    @place_type2.save!

    @place = Factory.build(:place)
    @place.place_types << @place_type1
    @place.place_types << @place_type2
    @place.save!
  end

  after { I18n.locale = :en }

  it 'should sort place types based on translated code description' do
    @place.reload
    @place.place_types.all(:order => 'code_description').collect(&:code_description).should == ['one', 'two']
    I18n.locale = :test
    @place.reload
    @place.place_types.all(:order => 'code_description').collect(&:code_description).should == ['Dead', 'Zed']
  end

end

describe ExternalCode, "finder sql with included associations" do
  before do
    @code = Factory.create :external_code
    @code.update_attributes!(:code_description => 'sample code')
    @code.code_translations.build(:locale => 'test', :code_description => 'test sample code').save!
    @code_name = Factory.create :code_name, :code_name => @code.code_name

    I18n.locale = :test
    @code.reload
  end

  after { I18n.locale = :en }

  it "still pulls the translated code_description" do
    results = ExternalCode.find(:all,
                                :include => :disease_specific_selections,
                                :conditions => ['disease_specific_selections.disease_id is NULL AND the_code = ?', @code.the_code])
    results.any? do |code|
      code.code_description == 'test sample code'
    end.should be_true
    results.size.should == 1
  end
end


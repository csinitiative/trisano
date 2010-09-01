require 'spec_helper'

describe CodeTranslation do

  before do
    @code = Factory.create :code
    @translation = @code.code_translations.for_locale(:en)
  end

  it "should only allow on entry per code, per locale" do
    clone = @translation.clone
    clone.save
    clone.errors.on(:locale).should == "has already been taken"
  end

  it "should belong to a code" do
    @translation.should belong_to(:code)
  end
end

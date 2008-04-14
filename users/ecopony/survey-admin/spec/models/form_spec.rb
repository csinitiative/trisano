require File.dirname(__FILE__) + '/../spec_helper'

describe Form do
  before(:each) do
    @form = Form.new
    
    disease = Disease.new({:name => "Tummy Ache"})
    jurisdiction = Jurisdiction.new({:name => "Bear River"})
    
    @form.disease = disease
    @form.jurisdiction = jurisdiction
    
  end

  it "should be valid" do
    @form.should be_valid
  end
end

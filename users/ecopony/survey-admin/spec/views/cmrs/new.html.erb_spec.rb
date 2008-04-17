require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/new.html.erb" do
  include CmrsHelper
  
  before(:each) do
    @cmr = mock_model(Cmr)
    @cmr.stub!(:new_record?).and_return(true)
    @cmr.stub!(:name).and_return("MyString")
    @cmr.stub!(:disease_id).and_return("1")
    @cmr.stub!(:jurisdiction_id).and_return("1")
    assigns[:cmr] = @cmr
  end

  it "should render new form" do
    render "/cmrs/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", cmrs_path) do
      with_tag("input#cmr_name[name=?]", "cmr[name]")
    end
  end
end



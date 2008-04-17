require File.dirname(__FILE__) + '/../../spec_helper'

describe "/cmrs/edit.html.erb" do
  include CmrsHelper
  
  before do
    @cmr = mock_model(Cmr)
    @cmr.stub!(:name).and_return("MyString")
    @cmr.stub!(:disease_id).and_return("1")
    @cmr.stub!(:jurisdiction_id).and_return("1")
    assigns[:cmr] = @cmr
  end

  it "should render edit form" do
    render "/cmrs/edit.html.haml"
    
    response.should have_tag("form[action=#{cmr_path(@cmr)}][method=post]") do
      with_tag('input#cmr_name[name=?]', "cmr[name]")
    end
  end
end



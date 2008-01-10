require File.dirname(__FILE__) + '/../../spec_helper'

describe "/ethnicities/new.html.erb" do
  include EthnicitiesHelper
  
  before(:each) do
    @ethnicity = mock_model(Ethnicity)
    @ethnicity.stub!(:new_record?).and_return(true)
    assigns[:ethnicity] = @ethnicity
  end

  it "should render new form" do
    render "/ethnicities/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", ethnicities_path) do
    end
  end
end



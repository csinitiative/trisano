require File.dirname(__FILE__) + '/../../spec_helper'

describe "/ethnicities/edit.html.erb" do
  include EthnicitiesHelper
  
  before do
    @ethnicity = mock_model(Ethnicity)
    assigns[:ethnicity] = @ethnicity
  end

  it "should render edit form" do
    render "/ethnicities/edit.html.erb"
    
    response.should have_tag("form[action=#{ethnicity_path(@ethnicity)}][method=post]") do
    end
  end
end



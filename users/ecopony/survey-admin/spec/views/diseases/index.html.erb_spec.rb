require File.dirname(__FILE__) + '/../../spec_helper'

describe "/diseases/index.html.erb" do
  include DiseasesHelper
  
  before(:each) do
    
    program = mock_model(Program)
    program.stub!(:name).and_return("Enterics")
    
    disease_98 = mock_model(Disease)
    disease_98.should_receive(:name).and_return("MyString")
    disease_98.stub!(:program).and_return(program)
    
    
    disease_99 = mock_model(Disease)
    disease_99.should_receive(:name).and_return("MyString")
    disease_99.stub!(:program).and_return(program)
    
    

    assigns[:diseases] = [disease_98, disease_99]
  end

  it "should render list of diseases" do
    render "/diseases/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end


require File.dirname(__FILE__) + '/../../spec_helper'

describe "/programs/show.html.erb" do
  include ProgramsHelper
  
  before(:each) do
    @program = mock_model(Program)
    @program.stub!(:name).and_return("MyString")

    assigns[:program] = @program
  end

  it "should render attributes in <p>" do
    render "/programs/show.html.haml"
    response.should have_text(/MyString/)
  end
end


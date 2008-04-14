require File.dirname(__FILE__) + '/../../spec_helper'

describe "/programs/index.html.erb" do
  include ProgramsHelper
  
  before(:each) do
    program_98 = mock_model(Program)
    program_98.should_receive(:name).and_return("MyString")
    program_99 = mock_model(Program)
    program_99.should_receive(:name).and_return("MyString")

    assigns[:programs] = [program_98, program_99]
  end

  it "should render list of programs" do
    render "/programs/index.html.haml"
    response.should have_tag("tr>td", "MyString", 2)
  end
end


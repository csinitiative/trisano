require File.dirname(__FILE__) + '/../../spec_helper'

describe "/programs/new.html.erb" do
  include ProgramsHelper
  
  before(:each) do
    @program = mock_model(Program)
    @program.stub!(:new_record?).and_return(true)
    @program.stub!(:name).and_return("MyString")
    assigns[:program] = @program
  end

  it "should render new form" do
    render "/programs/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", programs_path) do
      with_tag("input#program_name[name=?]", "program[name]")
    end
  end
end



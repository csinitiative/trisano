require File.dirname(__FILE__) + '/../../spec_helper'

describe "/programs/edit.html.erb" do
  include ProgramsHelper
  
  before do
    @program = mock_model(Program)
    @program.stub!(:name).and_return("MyString")
    assigns[:program] = @program
  end

  it "should render edit form" do
    render "/programs/edit.html.haml"
    
    response.should have_tag("form[action=#{program_path(@program)}][method=post]") do
      with_tag('input#program_name[name=?]', "program[name]")
    end
  end
end



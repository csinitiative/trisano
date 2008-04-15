require File.dirname(__FILE__) + '/../../spec_helper'

describe "/diseases/edit.html.erb" do
  include DiseasesHelper
  
  before do
    @disease = mock_model(Disease)
    @disease.stub!(:name).and_return("Enterics")
    @disease.stub!(:program_id).and_return(1)
    
    @forms = []
    
    assigns[:disease] = @disease
    assigns[:forms] = @forms
  end

  it "should render edit form" do
    render "/diseases/edit.html.haml"
    
    response.should have_tag("form[action=#{disease_path(@disease)}][method=post]") do
      with_tag('input#disease_name[name=?]', "disease[name]")
    end
  end
end



require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/cmrs.html.haml" do
  
  def do_render
    render "/search/cmrs.html.haml"
  end
  
  it "should render a search form" do
    assigns[:diseases] = [mock_disease]
    do_render
    response.should have_tag("form[action=?][method=get]", search_path + "/cmrs")
  end
  
  it "should show results when results are present" do
    
    cmr = mock_model(Object)
    cmr.stub!(:record_number).and_return("20083453")
    cmr.stub!(:event_id).and_return("1234567")
    cmr.stub!(:first_name).and_return("John")
    cmr.stub!(:middle_name).and_return("J")
    cmr.stub!(:last_name).and_return("Johnson")
    cmr.stub!(:disease_name).and_return("Chicken Pox")
    cmr.stub!(:event_onset_date).and_return("2008/12/12")
    cmr.stub!(:code_description).and_return("Salt Lake")

    assigns[:cmrs] = [cmr]
    assigns[params[:disease]] = "1"
    assigns[:diseases] = [mock_disease]
    
    do_render
    response.should have_tag("h3", "Results")
  end
  
  it "should show message when no results are present" do
    assigns[:cmr] = []
    params[:disease] = "1"
    assigns[:diseases] = [mock_disease]
    do_render
    response.should have_text(/Your search returned no results./)
  end
  
  def mock_disease
    disease = mock_model(Disease)
    disease.stub!(:id).and_return("1")
    disease.stub!(:disease_name).and_return("Chicken Pox")
    disease
  end
  
end

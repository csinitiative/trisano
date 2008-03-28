require File.dirname(__FILE__) + '/../../spec_helper'

describe "/search/cmrs.html.haml" do
  
  def do_render
    render "/search/cmrs.html.haml"
  end
  
  it "should render a search form" do
    assigns[:diseases] = [mock_disease]
    assigns[:genders] = [mock_gender]
    assigns[:cities] = [mock_gender]
    assigns[:counties] = [mock_county]
    assigns[:jurisdictions] = [mock_jurisdiction]
    assigns[:investigation_statuses] = [mock_investigation_status]
    do_render
    response.should have_tag("form[action=?][method=get]", search_path + "/cmrs")
  end
  
  it "should show results when results are present" do
    
    cmr = mock_model(Object)
    cmr.stub!(:record_number).and_return("20083453")
    cmr.stub!(:event_id).and_return("1234567")
    cmr.stub!(:entity_id).and_return("12")
    cmr.stub!(:first_name).and_return("John")
    cmr.stub!(:middle_name).and_return("J")
    cmr.stub!(:last_name).and_return("Johnson")
    cmr.stub!(:disease_name).and_return("Chicken Pox")
    cmr.stub!(:event_onset_date).and_return("2008/12/12")
    cmr.stub!(:birth_date).and_return("1977/1/12")
    cmr.stub!(:gender).and_return("Male")
    cmr.stub!(:city).and_return("Provo")
    cmr.stub!(:county).and_return("Salt Lake")
    cmr.stub!(:district).and_return("Alpine")
    cmr.stub!(:county).and_return("Salt Lake")
    cmr.stub!(:investigation_LHD_status_id).and_return("Not Yet Opened")
    cmr.stub!(:jurisdiction_name).and_return("Weber-Morgan Health District")

    assigns[:cmrs] = [cmr]
    assigns[params[:disease]] = "1"
    assigns[:diseases] = [mock_disease]
    assigns[:genders] = [mock_gender]
    assigns[:cities] = [mock_gender]
    assigns[:counties] = [mock_county]
    assigns[:jurisdictions] = [mock_jurisdiction]
    assigns[:districts] = [mock_district]
    assigns[:investigation_statuses] = [mock_investigation_status]

    do_render
    response.should have_tag("h3", "Results")
  end
  
  it "should show message when no results are present" do
    assigns[:cmr] = []
    params[:disease] = "1"
    assigns[:diseases] = [mock_disease]
    assigns[:genders] = [mock_gender]
    assigns[:cities] = [mock_gender]
    assigns[:counties] = [mock_county]
    assigns[:jurisdictions] = [mock_jurisdiction]
    assigns[:districts] = [mock_district]
    assigns[:investigation_statuses] = [mock_investigation_status]
    do_render
    response.should have_text(/Your search returned no results./)
  end
  
  def mock_disease
    disease = mock_model(Disease)
    disease.stub!(:id).and_return("1")
    disease.stub!(:disease_name).and_return("Chicken Pox")
    disease
  end
  
  def mock_gender
    gender = mock_model(Code)
    gender.stub!(:id).and_return("1")
    gender.stub!(:code_description).and_return("Male")
    gender
  end

  def mock_city
    city = mock_model(Code)
    city.stub!(:id).and_return("1")
    city.stub!(:code_description).and_return("Provo")
    city
  end

  def mock_county
    county = mock_model(Code)
    county.stub!(:id).and_return("1")
    county.stub!(:code_description).and_return("Salt Lake")
    county
  end

  def mock_place
    place = mock_model(Place)
    place.stub!(:name).and_return("Davis County")
    place
  end

  def mock_jurisdiction
    jurisdiction = mock_model(Entity)
    jurisdiction.stub!(:id).and_return("1")
    jurisdiction.stub!(:current_place).and_return(mock_place)
    jurisdiction
  end

  def mock_district
    district = mock_model(Code)
    district.stub!(:id).and_return("1")
    district.stub!(:code_description).and_return("Alpine")
    district
  end

  def mock_investigation_status
    status = mock_model(Code)
    status.stub!(:id).and_return("1702")
    status.stub!(:code_description).and_return("Not Yet Opened")
    status
  end
end

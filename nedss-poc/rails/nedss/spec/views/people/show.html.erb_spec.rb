require File.dirname(__FILE__) + '/../../spec_helper'

describe "/people/show.html.erb" do
  include PeopleHelper
  
  before(:each) do
    @person = mock_model(Person)
    @gender = @ethnicity = @race = @language = mock_model(Code)

    @gender.stub!(:code_description).and_return('Male')
    @ethnicity.stub!(:code_description).and_return('Hispanic')
    @race.stub!(:code_description).and_return('Asian')
    @language.stub!(:code_description).and_return('Spanish')

    @person.stub!(:last_name).and_return("Marx")
    @person.stub!(:first_name).and_return("Groucho")
    @person.stub!(:middle_name).and_return("Julius")
    @person.stub!(:birth_date).and_return('1890-10-2')
    @person.stub!(:date_of_death).and_return('1970-4-21')
    @person.stub!(:ethnicity).and_return(@ethnicity)
    @person.stub!(:birth_gender).and_return(@gender)
    @person.stub!(:current_gender).and_return(@gender)
    @person.stub!(:race).and_return(@gender)
    @person.stub!(:primary_language).and_return(@language)

    assigns[:person] = @person
  end

  it "should render attributes" do
    render "/people/show.html.erb"

    response.should have_text(/#{@person.last_name}/)
    response.should have_text(/#{@person.first_name}/)
    response.should have_text(/#{@person.middle_name}/)
    response.should have_text(/#{@person.birth_date}/)
    response.should have_text(/#{@person.date_of_death}/)
    response.should have_text(/#{@person.ethnicity.code_description}/)
    response.should have_text(/#{@person.birth_gender.code_description}/)
    response.should have_text(/#{@person.race.code_description}/)
    response.should have_text(/#{@person.primary_language.code_description}/)
  end
end


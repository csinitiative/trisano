require File.dirname(__FILE__) + '/../spec_helper'

describe Person, "with last name only" do
  before(:each) do
    @person = Person.new(:last_name => 'Lacey')
  end

  it "should be valid" do
    @person.should be_valid
  end

  it "should save without errors" do
    @person.save.should be_true
    @person.errors.should be_empty
  end
  
  it "should not have a Soundex code for first name" do
    @person.save.should be_true
    @person.first_name_soundex.should be_nil
  end
  
end

describe Person, "without a last name" do
  before(:each) do
    @person = Person.new
  end

  it "should not be valid" do
    @person.should_not be_valid
  end

  it "should not be saveable" do
    @person.save.should be_false
    @person.should have(1).error_on(:last_name)
  end
end

describe Person, "with first and last names" do

  it "should have Soundex codes after save" do
    first_name = 'Robert'
    last_name = 'Ford'
    
    @person = Person.new(:last_name => last_name, :first_name => first_name)
    
    @person.save.should be_true
    @person.first_name_soundex.should eql(Text::Soundex.soundex(first_name))
    @person.last_name_soundex.should eql(Text::Soundex.soundex(last_name))
  end

end

describe Person, "with associated codes" do
  fixtures :external_codes

  before(:each) do
    @ethnicity = ExternalCode.find_by_code_name('ethnicity')
    @gender = ExternalCode.find_by_code_name('gender')
    @person = Person.create(:last_name => 'Lacey', :ethnicity => @ethnicity, :birth_gender => @gender)
  end

  it "should retrieve with the same codes" do
    person = Person.find(@person.id)
    person.ethnicity.should eql(@ethnicity)
    person.birth_gender.should eql(@gender)
  end
end

describe Person, "with dates of birth and/or death" do
  it "should allow only valid dates" do
    person = Person.new(:last_name => 'Lacey', :birth_date => "2007-02-29", :date_of_death => "today")
    person.should_not be_valid
    person.should have(1).error_on(:birth_date)
    person.should have(1).error_on(:date_of_death)

    person = Person.new(:last_name => 'Lacey', :birth_date => "2008-02-29", :date_of_death => "02/28/2009")
    person.should be_valid
  end

  it "should not be valid to die before being born" do
    person = Person.new(:last_name => 'Lacey', :birth_date => "2008-12-31", :date_of_death => "2008-12-30")
    person.should_not be_valid
  end

  it "should be valid to die after being born" do
    person = Person.new(:last_name => 'Lacey', :birth_date => "2007-12-31", :date_of_death => "2008-12-30")
    person.should be_valid
  end
end

describe Person, "loaded from fixtures" do
  fixtures :people, :external_codes

  it "should have a non-empty collection of people" do
    Person.find(:all).should_not be_empty
  end

  it "should find an existing person" do
    person = Person.find(people(:groucho_marx).id)
    person.should eql(people(:groucho_marx))
  end

  it "should have an ethnicity of other" do
    people(:groucho_marx).ethnicity.should eql(external_codes(:ethnicity_other))
  end

  it "should have a birth_gender of male" do
    people(:groucho_marx).birth_gender.should eql(external_codes(:gender_male))
  end

  it "should have a primary language of Spanish" do
    people(:groucho_marx).primary_language.should eql(external_codes(:language_spanish))
  end
end

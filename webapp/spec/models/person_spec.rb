# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

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

  it "should have full name 'Robert Ford'" do
    first_name = 'Robert'
    last_name = 'Ford'
    person = Person.new(:last_name => last_name, :first_name => first_name)
    person.full_name.should == 'Robert Ford'
  end

end

describe Person, "with associated codes" do
  before(:each) do
    @ethnicity = ExternalCode.find_by_code_name('ethnicity')
    @gender = ExternalCode.find_by_code_name('gender')
    @person = Person.create(:last_name => 'Lacey',
      :ethnicity => @ethnicity,
      :birth_gender => @gender)
  end

  it "should retrieve with the same codes" do
    person = Person.find(@person.id)
    person.ethnicity.should eql(@ethnicity)
    person.birth_gender.should eql(@gender)
  end
end

describe Person, "with dates of birth and/or death" do
  before(:each) do
    @person = Person.new(:last_name => 'Lacey')
  end

  it "should allow only valid dates" do
    params = {:birth_date => "2007-02-29", :date_of_death => "today"}
    @person.update_attributes(params)
    @person.errors.on("birth_date").should == "is not a valid date"
    @person.errors.on("date_of_death").should == "is not a valid date"

    @person.update_attributes(:birth_date => "2008-02-29", :date_of_death => "02/28/2009")
    @person.should be_valid
  end

  it "should not allow date_of_death to occur before birth_date" do
    params = {:birth_date => Date.today, :date_of_death => Date.yesterday}
    @person.update_attributes(params)
    @person.errors.on("date_of_death").should == "must be on or after " + Date.today.to_s
  end

  it "should be valid to die after being born" do
    params = {:birth_date => Date.yesterday, :date_of_death => Date.today}
    @person.update_attributes(params)
    @person.should be_valid
  end

  it "should allow a date_of_death in the past" do
    @person.update_attributes(:date_of_death => Date.yesterday)
    @person.should be_valid
    @person.errors.on(:date_of_death).should be_nil
  end

  it "should not allow a date_of_death in the future" do
    @person.update_attributes(:date_of_death => Date.tomorrow)
    @person.errors.on(:date_of_death).should == "must be on or before " + Date.today.to_s
  end

  it "should allow a date_of_death in the past" do
    @person.update_attributes(:birth_date => Date.yesterday)
    @person.should be_valid
    @person.errors.on(:birth_date).should be_nil
  end

  it "should not allow a birth_date in the future" do
    @person.update_attributes(:birth_date => Date.tomorrow)
    @person.errors.on(:birth_date).should == "must be on or before " + Date.today.to_s
  end

  it "should calculate an age if birth_date is not blank" do
    @person.update_attributes(:birth_date => 10.years.ago)
    @person.age.should == 10
  end

  it "should not calculate an age if the birth_date is blank" do
    @person.update_attributes(:birth_date => nil)
    @person.age.should be_nil
  end

end

describe Person, "exists" do
  before do
    @person = Factory.build(:person)
    @person.ethnicity = external_codes(:ethnicity_other)
    @person.birth_gender = external_codes(:gender_male)
    @person.primary_language = external_codes(:language_spanish)
    @person.save!
  end

  it "should have a non-empty collection of people" do
    Person.find(:all).should_not be_empty
  end

  it "should find an existing person" do
    person = Person.find(@person.id)
    person.should eql(@person)
  end

  it "should have an ethnicity of other" do
    @person.ethnicity.should eql(external_codes(:ethnicity_other))
  end

  it "should have a birth_gender of male" do
    @person.birth_gender.should eql(external_codes(:gender_male))
  end

  it "should have a primary language of Spanish" do
    @person.primary_language.should eql(external_codes(:language_spanish))
  end

  it "should look up the birth gender description" do
    @person.birth_gender_description.should eql('Male')
  end

  it "should look up the ethnicity description" do
    @person.ethnicity_description.should eql('Other')
  end

  it "should look up the primary language description" do
    @person.primary_language_description.should eql('Spanish')
  end
end

describe Person, "with one or more races" do
  it "should look up the race description" do
    entity = Factory.build(:person_entity)
    entity.stubs(:races).returns([external_codes(:race_white)])
    person = Person.new(:last_name => 'Entwistle')
    person.stubs(:person_entity).returns(entity)
    person.race_description.should eql('White')
  end

  it "should build a race description if several races" do
    entity = Factory.build(:person_entity)
    entity.stubs(:races).returns([external_codes(:race_white), external_codes(:race_asian), external_codes(:race_indian)])
    person = Person.new(:last_name => 'Entwistle')
    person.stubs(:person_entity).returns(entity)
    person.race_description.should eql('White, Asian and American Indian')
  end

  it "should not be an error to have no race" do
    entity = Factory.build(:person_entity)
    entity.stubs(:races).returns([])
    person = Person.new(:last_name => 'Entwistle')
    person.stubs(:person_entity).returns(entity)
    person.race_description.should be_nil
  end

end

describe Person, 'named scopes for clinicians' do

  before(:each) do
    @clinician = Factory.create(:person_entity, :person => Factory.create(:clinician))
    @clinician_2 = Factory.create(:person_entity, :person => Factory.create(:clinician))
    @deleted_clinician = Factory.create(:person_entity, :person => Factory.create(:clinician), :deleted_at => Time.now)
    @non_clinician = Factory.create(:person_entity, :person => Factory.create(:person))
  end

  it "should return all clinicians" do
    Person.clinicians.size.should == 3
    Person.clinicians.detect { |clinician| clinician.person_entity.id == @deleted_clinician.id }.should_not be_nil
    Person.clinicians.detect { |clinician| clinician.person_entity.id == @non_clinician.id }.should be_nil
  end

  it "should return all active clinicians" do
    Person.active_clinicians.size.should == 2
    Person.active_clinicians.detect { |clinician| clinician.person_entity.id == @deleted_clinician.id }.should be_nil
    Person.active_clinicians.detect { |clinician| clinician.person_entity.id == @non_clinician.id }.should be_nil
  end

end

# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

require 'spec_helper'

describe Person do

  context "with last name only" do
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

  context "without a last name" do
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

  context "with first and last names" do
    it "should have full name 'Robert Ford'" do
      first_name = 'Robert'
      last_name = 'Ford'
      person = Person.new(:last_name => last_name, :first_name => first_name)
      person.full_name.should == 'Robert Ford'
    end
  end

  context "with associated codes" do
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

  context "with dates of birth and/or death" do
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

  context "exists" do
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

  context "with one or more races" do
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

  describe "named scopes for clinicians" do
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
      Person.active.clinicians.size.should == 2
      Person.active.clinicians.detect { |clinician| clinician.person_entity.id == @deleted_clinician.id }.should be_nil
      Person.active.clinicians.detect { |clinician| clinician.person_entity.id == @non_clinician.id }.should be_nil
    end
  end

  context "reporters search" do
    let(:reporter) do
      Factory.create(:reporter).person
    end

    it "should return reporters" do
      Person.reporters.should be_empty
      reporter.should_not be_nil
      Person.reporters.should == [reporter]
    end
    
    it "should not return duplicate reporters" do
      lambda do
        Factory.create(:reporter, :secondary_entity => reporter.person_entity)
      end.should change(Reporter, :count).by(2)
      Person.reporters.count.should == 1
    end

    it "should be able to return only active (not deleted) reporters" do
      reporter.person_entity.update_attributes(:deleted_at => DateTime.now).should be_true
      Person.reporters.should == [reporter]
      Person.active.reporters.should == []
    end

  end

  context "with an associated disease event" do
    before do
      @entity = Factory.create(:person_entity, :person => Factory.create(:person))

      @event = Factory.create(:morbidity_event)
      @event.interested_party.person_entity = @entity
      @event.interested_party.save

      @disease_event = Factory.create(:disease_event, :event => @event)
      @event.disease_event = @disease_event
      @event.save
    end

    it 'should not be dead if disease event does not indicate whether or not there was death' do
      @entity.person.dead?.should be_false
    end

    it 'should not be dead if disease event does not indicate death' do
      @disease_event.died = external_code!('yesno', 'N')
      @disease_event.save
      @entity.person.dead?.should be_false
    end

    it 'should be dead if disease event indicates death' do
      @disease_event.died = external_code!('yesno', 'Y')
      @disease_event.save
      @entity.person.dead?.should be_true
    end

    it 'should be dead if only one disease event indicates death' do
      new_event = Factory.create(:morbidity_event)
      new_event.interested_party.person_entity = @entity
      new_event.interested_party.save

      new_disease_event = Factory.create(:disease_event, :event => new_event)
      new_event.disease_event = new_disease_event
      new_event.save

      new_disease_event.died = external_code!('yesno', 'Y')
      new_disease_event.save

      @entity.person.dead?.should be_true
    end
  end

  describe "#last_comma_first_middle" do
    before do
      @person = Person.create(:first_name => 'John', :last_name => 'Public')
    end

    it 'should render correctly without a middle name' do
      @person.last_comma_first_middle.should == "Public, John"
    end

    it 'should render correctly with a middle name' do
      @person.update_attributes(:middle_name => 'Q')
      @person.last_comma_first_middle.should == "Public, John Q"
    end
  end

  describe "class methods" do

    describe "types" do
      it "all types returned should be names of sub-classes of Participation" do
        Person.valid_search_types.each do |type|
          obj = eval(type[1]).new
          obj.is_a?(Participation).should be_true
          obj.respond_to?(:person_entity).should be_true
          obj.respond_to?(:place_entity).should be_false
        end
      end
    end

  end

end


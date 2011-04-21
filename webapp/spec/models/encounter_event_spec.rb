require 'spec_helper'

describe EncounterEvent do

  it "encounter date cannot occur before patient's birth date" do
    ee = Factory.create :encounter_event
    ee.interested_party.person_entity.person.birth_date = Date.today
    ee.build_participations_encounter :encounter_date => Date.yesterday
    ee.validate_against_bday = true
    ee.save
    ee.errors.on(:base).should == "Encounter date(s) precede birth date"
    ee.participations_encounter.errors.on(:encounter_date).should == "cannot be earlier than birth date"
  end

  it "generates a note when created" do
    event = Factory.create :encounter_event
    event.notes.size.should == 1
  end

  it "generate a note when edited" do
    event = Factory.create :encounter_event
    event.update_attribute :participations_encounter_attributes, :description => "updated"
    event.notes.size.should == 2
  end

  it "should not add a not if the event or participation isn't dirty" do
    event = Factory.create :encounter_event
    event.save!
    event.notes.size.should == 1
  end

end

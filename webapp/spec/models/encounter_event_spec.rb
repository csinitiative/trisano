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

end

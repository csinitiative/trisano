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

describe EncounterEvent do

  before do
    @event = Factory.create :encounter_event
    @parent_event = @event.parent_event
    @parent_event.create_disease_event :disease => Factory.create(:disease)
    @parent_event.associated_jurisdictions.create :secondary_entity => create_jurisdiction_entity
  end

  it "encounter date cannot occur before patient's birth date" do
    @event.interested_party(true).person_entity.person.birth_date = Date.today
    @event.build_participations_encounter :encounter_date => Date.yesterday
    @event.validate_against_bday = true
    @event.save
    @event.errors.on(:base).should == "Encounter date(s) precede birth date"
    @event.participations_encounter.errors.on(:encounter_date).should == "cannot be earlier than birth date"
  end

  it "generates a note when created" do
    @event = Factory.create :encounter_event
    @event.notes.size.should == 1
  end

  it "generate a note when edited" do
    @event = Factory.create :encounter_event
    @event.update_attribute :participations_encounter_attributes, :description => "updated"
    @event.notes.size.should == 2
  end

  it "should not add a note if the @event or participation isn't dirty" do
    @event = Factory.create :encounter_event
    @event.save!
    @event.notes.size.should == 1
  end

  it "should use the same disease event instance as its parent" do
    @parent_event.disease_event.should_not be_nil
    @event.disease_event(true).should_not be_nil
    @event.disease_event.should == @parent_event.disease_event
  end

  it "should use the same jurisidiction instance as its parent" do
    @parent_event.jurisdiction.should_not be_nil
    @event.jurisdiction(true).should_not be_nil
    @event.jurisdiction.should == @parent_event.jurisdiction
  end

  it "should use the same secondary jurisdictions as its parent" do
    @parent_event.associated_jurisdictions.should_not be_empty
    @event.associated_jurisdictions(true).should_not be_empty
    @event.associated_jurisdictions.should == @parent_event.associated_jurisdictions
  end

  it "should use a different interested party instance of the patient as its parent" do
    @parent_event.interested_party.should_not be_nil
    @event.interested_party(true).should_not be_nil
    @event.interested_party.should_not eql(@parent_event.interested_party)
    @event.interested_party.person_entity.should == @parent_event.interested_party.person_entity
  end

  it "should not try to validate associated disease events" do
    DiseaseEvent.update_all "date_diagnosed = '#{Date.tomorrow.to_s(:db)}'::date", "event_id = #{@parent_event.id}"
    @event.disease_event(true).should_not be_nil
    @event.should be_valid
  end

  it "should not try to validate the associated interested party" do
    Person.update_all "last_name = ''", "entity_id = #{@parent_event.interested_party.primary_entity_id}"
    @event.interested_party(true).should_not be_nil
    @event.should be_valid
  end

  it "should use parent's jurisdictions in #all_jurisdictions association" do
    @event.all_jurisdictions.should == @parent_event.all_jurisdictions
  end
end

require File.dirname(__FILE__) + '/../spec_helper'

describe ContactEvent do

  describe "Initializing a new contact event from an existing morbidity event" do

    patient_attrs = {
      :disease => { :disease_id => 1},
      "active_patient" => {
        "active_primary_entity" => {
          "entity_type"=>"person", 
          "person" => {
            "last_name"=>"Green"
          }
        }
      },
      :active_jurisdiction => { 
        :secondary_entity_id => 1
      }
    }

    describe "When event has no contacts" do
      it "should return an empty array" do
        event = MorbidityEvent.new(patient_attrs)
        contact_events = ContactEvent.initialize_from_morbidity_event(event)
        contact_events.class.should eql(Array)
        contact_events.length.should == 0
      end
    end

    describe "When event has one contact" do
      
      before(:each) do
        contact_hash = { :new_contact_attributes => [ {:last_name => "White"} ] }
        event = MorbidityEvent.new(patient_attrs.merge(contact_hash))
        @contact_events = ContactEvent.initialize_from_morbidity_event(event)
      end

      it "should return a one element array" do
        @contact_events.length.should == 1
      end

      it "should have a single contact_event in the array" do
        @contact_events.first.class.should eql(ContactEvent)
      end

      describe "the returned contact" do
        before(:each) do
          @contact_event = @contact_events.first
        end

        it "should have a primary entity equal to the original contact" do
          @contact_event.participations.each do |participation|
            if participation.role_id == 2301 #interested party
              participation.primary_entity.person.last_name.should == "White"
            end
          end
        end

        it "should have the same jurisdiction as the original contact" do
          @contact_event.participations.each do |participation|
            if participation.role_id == 2305 #jurisdiction
              participation.secondary_entity_id.should == 1
            end
          end
        end

        it "should have the original patient as a contact" do
          @contact_event.participations.each do |participation|
            if participation.role_id == 2307 #contact
              participation.secondary_entity.person.last_name.should == "Green"
            end
          end
        end

        it "should have the same disease as the original" do
          @contact_event.disease.disease_id.should == 1
        end
      end
    end

    describe "when event has two contacts" do
      it "should return an array of two elements" do
        contact_hash = { :new_contact_attributes => [ {:last_name => "White"}, {:last_name => "Black"} ] }
        event = MorbidityEvent.new(patient_attrs.merge(contact_hash))
        contact_events = ContactEvent.initialize_from_morbidity_event(event)
        contact_events.length.should == 2
      end
    end

  end
end

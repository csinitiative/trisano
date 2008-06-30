require File.dirname(__FILE__) + '/../spec_helper'

describe Event do

  event_hash = {
    "event_onset_date" => "June 28, 2008",
    "active_patient" => {
      "active_primary_entity" => {
        "entity_type"=>"person", 
        "person" => {
          "last_name"=>"Green"
        }
      }
    }
  }

  fixtures :events, :participations, :entities, :places, :people, :lab_results

  describe "handling new labs and lab results" do

    describe "receiving a new lab and lab result" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>"New Lab One Result"}
            ]
        }
        @event = Event.new(event_hash.merge(new_lab_hash_1))
      end

      it "should create a new participation linked to the event" do
        lambda {@event.save}.should change {Participation.count}.by(2)
        @event.participations.find_by_role_id(codes(:participant_testing_lab).id).should_not be_nil
      end

      it "should add a new lab" do
        lambda {@event.save}.should change {Place.count}.by(1)
        @event.labs.first.secondary_entity.places.first.name.should == "New Lab One"
      end

      it "should add a new lab result" do
        lambda {@event.save}.should change {LabResult.count}.by(1)
        @event.labs.first.lab_results.first.lab_result_text.should == "New Lab One Result"
      end
    end

    describe "receiving an existing lab and a new lab result" do

      before(:each) do
        exisitng_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
        }
        @event = Event.new(event_hash.merge(exisitng_lab_hash_1))
      end

      it "should not create a new lab" do
        lambda {@event.save}.should_not change {Place.count}
      end

      it "should link to the existing lab" do
        @event.save
        @event.labs.first.secondary_entity.should eql(entities(:Existing_Lab_One))
      end

      it "should add a new lab result" do
        lambda {@event.save}.should change {LabResult.count}.by(1)
        @event.labs.first.lab_results.first.lab_result_text.should == "Existing Lab Result"
      end
    end

    describe "receiving a lab with no lab result" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>""}
            ]
        }
        @event = Event.new(event_hash.merge(new_lab_hash_1))
      end

      it "should be invalid" do
        @event.should_not be_valid
        @event.labs.first.lab_results.first.should have(1).error_on(:lab_result_text)
      end

    end

    describe "receiving a lab result with no lab" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"", "lab_result_text"=>"Whatever"}
            ]
        }
        @event = Event.new(event_hash.merge(new_lab_hash_1))
      end

      it "should do nothing" do
        @event.should be_valid
        @event.labs.should be_empty
      end
    end

    describe "receiving two labs/lab results, one old one new" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              { "lab_entity_id" => nil, "name"=>"New Lab One", "lab_result_text"=>"New Lab One Result"},
              { "lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
        }
        @event = Event.new(event_hash.merge(new_lab_hash_1))
      end

      it "should create one new lab" do
        lambda {@event.save}.should change {Place.count}.by(1)
        @event.labs.first.secondary_entity.places.first.name.should == "New Lab One"
      end
      
      it "should create two new lab results" do
        lambda {@event.save}.should change {LabResult.count}.by(2)
      end

      it "should create three participations (1 patient + 2 labs)" do
        lambda {@event.save}.should change {Participation.count}.by(3)
      end
    end

    describe "receiving two labs, both existing" do

      before(:each) do
        new_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"},
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"Existing Lab Result"}
            ]
        }
        @event = Event.new(event_hash.merge(new_lab_hash_1))
      end

      it "should not create any new labs" do
        lambda {@event.save}.should_not change {Place.count}
      end

      it "should create two new lab results" do
        lambda {@event.save}.should change {LabResult.count}.by(2)
      end
    end

    describe "receiving a new lab result for an existing event and participation" do
      before(:each) do
        existing_lab_hash_1 = {
          "new_lab_attributes" => 
            [
              {"lab_entity_id" => places(:Existing_Lab_One).id, "name"=> places(:Existing_Lab_One).name, "lab_result_text"=>"A new result"}
            ]
        }
        @new_lab_hash = event_hash.merge(existing_lab_hash_1)
        @event = Event.find(events(:marks_cmr).id)
      end

      it "should not create any participations" do
        lambda {@event.update_attributes(@new_lab_hash)}.should_not change {Participation.count}
      end

      it "should create one new lab result" do
        lambda {@event.update_attributes(@new_lab_hash)}.should change {LabResult.count}.by(1)
      end
    end
  end

  describe "handling exisiting lab results" do

    describe "receiving an edited lab result" do

      before(:each) do
        @existing_lab_hash_1 = {
          "existing_lab_attributes" => { "#{lab_results(:lab_guys_lab_result).id}" => {"lab_result_text"=>"Negative"}}
        }
        @event = Event.find(events(:marks_cmr).id)
      end

      it "should update the existing lab_result" do
        lambda {@event.update_attributes(@existing_lab_hash_1)}.should_not change {LabResult.count}
        @event.labs.first.lab_results.first.lab_result_text.should == "Negative"
      end
    end

    describe "receiving no lab results" do

      before(:each) do
        @existing_lab_hash_1 = {
          "existing_lab_attributes" => {}
        }
        @event = Event.find(events(:marks_cmr).id)
      end

      it "should delete existing lab results and participation" do
        lambda {@event.update_attributes(@existing_lab_hash_1)}.should change {LabResult.count + Participation.count}.by(-2)
      end

    end

  end

end

require File.dirname(__FILE__) + '/../spec_helper'

describe Participation do
  
  describe 'patient participation' do

    before :each do
      @pt = Participation.new_patient_participation
      @pt.save
    end

    it 'should be an interested party' do
      @pt.role_id.should == Code.interested_party.id
    end

    it 'should have a primary entity' do
      @pt.primary_entity.should_not be_nil
    end

    it 'should have an associated person through primary entity' do
      @pt.primary_entity.person_temp.should_not be_nil
    end

    it 'should have at least one telephone entities location (to seed the ui)' do
      @pt.primary_entity.telephone_entities_locations.should_not be_empty
    end
  end

end
    
    

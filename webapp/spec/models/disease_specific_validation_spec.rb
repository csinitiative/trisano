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

require File.dirname(__FILE__) + '/../spec_helper'

describe DiseaseSpecificValidation do
  before(:each) do
    @disease = Factory.create(:disease)
    @dsv = DiseaseSpecificValidation.create(:disease => @disease, :validation_key => 'some_field_is_required')
  end

  it { should belong_to(:disease) }

  it "should be valid" do
    @dsv.should be_valid
  end

  it "should not be valid without a disease or a validation key" do
    @dsv = DiseaseSpecificValidation.create
    @dsv.valid?.should be_false
    @dsv.errors_on(:disease_id).should_not be_empty
    @dsv.errors_on(:validation_key).should_not be_empty
  end

  describe "returning diseases" do
    before(:each) do
      @another_disease_w_same_key_mapping = Factory.create(:disease)
      @disease_with_different_key_mapping = Factory.create(:disease)

      DiseaseSpecificValidation.create(:disease => @another_disease_w_same_key_mapping, :validation_key => 'some_field_is_required')
      DiseaseSpecificValidation.create(:disease => @disease_with_different_key_mapping, :validation_key => 'some_field_is_not_too_big')
    end

    it "should return disease ids for a key" do
      disease_ids = DiseaseSpecificValidation.diseases_ids_for_key("some_field_is_required")
      disease_ids.size.should == 2
      disease_ids.include?(@disease.id).should be_true
      disease_ids.include?(@another_disease_w_same_key_mapping.id).should be_true
      disease_ids.include?(@disease_with_different_key_mapping.id).should be_false

      disease_ids = DiseaseSpecificValidation.diseases_ids_for_key("some_field_is_not_too_big")
      disease_ids.size.should == 1
      disease_ids.include?(@disease.id).should be_false
      disease_ids.include?(@another_disease_w_same_key_mapping.id).should be_false
      disease_ids.include?(@disease_with_different_key_mapping.id).should be_true
    end
  end
  
  describe "creating associations" do

    before(:each) do
      @disease = Factory.create(:disease, :disease_name => 'The Tick Bite Fever')
      
      @dsv_hashes = [
        {"disease_name"=>"The Tick Bite Fever", "validation_key"=>"tick_bite_treatment_date_required"},
        {"disease_name"=>"The Tick Bite Fever", "validation_key"=>"tick_bite_disposition_date_required"}
      ]
    end

    it "should create the association" do
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should change {DiseaseSpecificValidation.count}.by(2)
    end

    it "should fail if the disease cannot be found" do
      @dsv_hashes << {"disease_name"=>"Le Tick Bite Fever", "validation_key"=>"le_tick_bite_validation"}
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should raise_error(RuntimeError)
    end

    it "should not load duplicates" do
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should change {DiseaseSpecificValidation.count}.by(2)
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should change {DiseaseSpecificValidation.count}.by(0)
    end

    it "should fail if an element in the hash is missing disease_name" do
      @dsv_hashes << {"validation_key"=>"le_tick_bite_validation"}
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should raise_error(RuntimeError)
    end

    it "should fail if an element in the hash is missing validation_key" do
      @dsv_hashes << {"disease_name"=>"The Tick Bite Fever"}
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should not fail if there are extra attributes in the hash" do
      @dsv_hashes << {"disease_name"=>"The Tick Bite Fever", "validation_key"=>"validation_with_an_extra_attribute", "extra_attribute" => "extra stuff"}
      lambda { DiseaseSpecificValidation.create_associations(@dsv_hashes) }.should change {DiseaseSpecificValidation.count}.by(3)
    end
  end
  
end
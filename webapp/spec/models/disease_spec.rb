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

describe Disease do

  before :all do
    destroy_fixture_data
  end

  after :all do
    Fixtures.reset_cache
  end

  let(:new_disease) { Disease.new(:disease_name => "The Pops") }

  it { should have_many(:organisms) }
  it { should have_many(:core_fields_diseases) }
  it { should have_many(:core_fields) }
  it { should have_many(:treatments) }
  it { should have_many(:disease_specific_treatments) }
  it { should have_and_belong_to_many(:export_columns) }

  it "should have many exportable statuses" do
    should have_and_belong_to_many(:cdc_disease_export_statuses)
  end

  it "should have many disease specific selections" do
    should have_many(:disease_specific_selections)
  end

  it "should be valid" do
    new_disease.should be_valid
  end

  it "should not be active" do
    new_disease.should_not be_active
  end

  it "can be made active" do
    new_disease.active = true
    new_disease.save.should be_true
    new_disease.should be_active
  end

  it "should not be sensitive" do
    new_disease.should_not be_sensitive
  end

  it "can be made sensitive" do
    new_disease.sensitive = true
    new_disease.save.should be_true
    new_disease.should be_sensitive
  end

  it '#find_active should not return inactive diseases' do
    new_disease.save.should be_true
    Disease.find(:all).size.should >= 1
    Disease.find_active(:all).size.should == 0
  end

  it '#find_active should return active diseases' do
    new_disease.active = true
    new_disease.save.should be_true
    Disease.find_active(:all).size.should == 1
  end

  it "#diseases_for_event should return a collection of active diseases for a select list" do
    Factory.create(:disease, :active => true)
    Factory.create(:disease, :active => true)
    Factory.create(:disease, :active => false)
    event = Factory.create(:morbidity_event)
    diseases = Disease.diseases_for_event(event)
    diseases.size.should == 2
  end

  it "#diseases_for_event should also return an inactive disease if it is associated with the event" do
    Factory.create(:disease, :active => true)
    Factory.create(:disease, :active => true)
    deactivated_disease = Factory.create(:disease, :active => false)
    event = Factory.create(:morbidity_event_with_disease)
    event.disease_event.disease = deactivated_disease
    event.save!
    diseases = Disease.diseases_for_event(event)
    diseases.size.should == 3
    diseases.detect {|disease| disease.disease_name == deactivated_disease.disease_name }.should_not be_nil
  end

  context "filtering for sensitive diseases" do
    before  do
      @user = Factory.build(:user)
      @disease = Factory.create(:disease)
      @sensitive_disease = Factory.create(:disease, :sensitive => true)
      @event = Factory.build(:morbidity_event)
    end

    it "should not return sensitive diseases if user doesn't have the privilege" do
      @user.stubs(:can_access_sensitive_diseases?).returns(false)
      Disease.sensitive(@user, @event).should == [@disease]
    end

    it "returns all diseases including sensitive if user is permitted to see sensitive diseases" do
      @user.stubs(:can_access_sensitive_diseases?).returns(true)
      Disease.sensitive(@user, @event).should == [@disease, @sensitive_disease]
    end
  end

  context "testing sensitive disease visibility" do
    before :each do
      @sensitive_role = create_role_with_privileges! 'Sensitive', :access_sensitive_diseases
      @privileged_user = create_user_in_role! 'Sensitive', 'Privileged User'
    end

    let(:unprivileged_user) { Factory :user }
    let(:nonsensitive_disease) { Factory :disease }
    let(:sensitive_disease) { Factory :disease, :sensitive => true }

    it "does not show sensitive diseases to unprivileged users" do
      sensitive_disease.should_not be_visible_to(unprivileged_user)
    end

    it "shows non-sensitive diseases to unprivileged users" do
      nonsensitive_disease.should be_visible_to(unprivileged_user)
    end

    it "shows sensitive diseases to privileged users" do
      sensitive_disease.should be_visible_to(@privileged_user)
    end

    it "shows non-sensitive diseases to privileged users" do
      nonsensitive_disease.should be_visible_to(@privileged_user)
    end

    it "accounts for the privilege by jurisdiction" do
      jurisdiction_ids = [ create_jurisdiction_entity.id ]
      sensitive_disease.should_not be_visible_to_in(@privileged_user, jurisdiction_ids)

      jurisdiction_ids << @sensitive_role.role_memberships.first.jurisdiction_id
      sensitive_disease.should be_visible_to_in(@privileged_user, jurisdiction_ids)
    end
  end

  it "should return its live forms" do
    new_disease.save.should be_true

    form = Form.new({
        :name => "Test Form",
        :event_type => "morbidity_event",
        :disease_ids => [new_disease.id],
        :short_name => 'disease_spec_short'
      }
    )

    form.save_and_initialize_form_elements
    new_disease.live_forms.should be_empty
    published_form = form.publish
    published_form.should_not be_nil
    live_forms = new_disease.live_forms
    live_forms.should_not be_empty
    live_forms[0].id.should eql(published_form.id)
    live_forms = new_disease.live_forms("PlaceEvent")
    live_forms.should be_empty
  end

  describe "loading from a YAML file" do
    before :all do
      scale = ExternalCode.find_by_code_name_and_the_code('loinc_scale', 'Ord') || Factory(:scale_code)
      Factory(:loinc_code, :loinc_code => '10007-0', :scale => scale)
      Factory(:loinc_code, :loinc_code => '20002-0', :scale => scale)
      Factory(:loinc_code, :loinc_code => '20001-0', :scale => scale)
    end

    before do
      Disease.create! :disease_name => 'Already here'
      Organism.create! :organism_name => 'Pre-existing Allan'
      @yaml = <<-"end-yaml"
        ---
        Sample Group:
          :diseases:
            - :disease_name: Clumsy
              :cdc_code: 99100
            - :disease_name: Already here
          :organisms:
            - :organism_name: Steve
            - :organism_name: Pre-existing Allan
          :loinc_codes:
            - :loinc_code: 10007-0
            - :loinc_code: 20002-0
            - :loinc_code: 20001-0
      end-yaml
    end

    it "should create diseases if they don't exist" do
      lambda {Disease.load_from_yaml(@yaml)}.should change(Disease, :count).by(1)
    end

    it "should load all provided attributes" do
      Disease.load_from_yaml(@yaml)
      disease = Disease.find_by_disease_name 'Clumsy'
      disease.should_not be_nil
      disease.cdc_code.should == "99100"
    end

    it 'should default created diseases to active' do
      Disease.load_from_yaml(@yaml)
      disease = Disease.find_by_disease_name 'Clumsy'
      disease.should_not be_nil
      disease.active.should be_true
    end

    it "should create organisms if they don't already exist" do
      lambda {Disease.load_from_yaml(@yaml)}.should change(Organism, :count).by(1)
    end

    it "should link organisms to diseases" do
      Disease.load_from_yaml(@yaml)
      organisms = Organism.all(:conditions => ['organism_name IN (?)', ['Pre-existing Allan', 'Steve']])
      organisms.size.should == 2
      Disease.find_by_disease_name('Clumsy').organisms.sort_by(&:organism_name).should == organisms
      Disease.find_by_disease_name('Already here').organisms.sort_by(&:organism_name).should == organisms
    end

    it "should link loinc codes to diseases" do
      Disease.load_from_yaml(@yaml)
      loincs = LoincCode.all(:conditions => ['loinc_code IN (?)', %w(10007-0 20001-0 20002-0)])
      loincs.size.should == 3
      Disease.find_by_disease_name('Clumsy').loinc_codes.should == loincs
      Disease.find_by_disease_name('Already here').loinc_codes.should == loincs
    end

  end

  describe 'export statuses' do
    it 'should initialize w/ zero export statuses' do
      new_disease.cdc_disease_export_statuses.should be_empty
    end

    describe 'associating cases' do

      it 'should add export case status' do
        codes = ExternalCode.find_cases(:all).select {|s| %w(Probable Suspect).include?(s.code_description)}
        codes.length.should == 2
        new_disease.update_attributes('cdc_disease_export_status_ids' => codes.map(&:id))
        new_disease.save!
        new_disease.cdc_disease_export_statuses.length.should == 2
      end
    end

  end

  describe 'diseases w/ no export status' do

    it 'should only return diseases with no specified cdc export status' do
      Disease.with_no_export_status.each do |disease|
        disease.cdc_disease_export_statuses.length.should == 0
      end
    end

  end

  describe 'diseases w/a CDC export code' do

    it 'it should create and update corresponding conversion values on save' do
      export_column = Factory(:export_column, :export_column_name => "EVENT")

      new_disease.cdc_code = "123456"
      new_disease.save.should be_true
      export_conversion_value = ExportConversionValue.find_by_export_column_id_and_value_from(export_column.id, new_disease.disease_name)
      export_conversion_value.should_not be_nil
      export_conversion_value.value_to.should eql(new_disease.cdc_code)

      new_disease.cdc_code = "654321"
      new_disease.save.should be_true
      export_conversion_value.reload
      export_conversion_value.value_to.should eql(new_disease.cdc_code)

    end
  end

  describe "applying core fields to another disease" do

    before do
      given_core_fields_loaded

      @lycanthropy = create_disease('Lycanthropy')
      @lycanthropy.core_fields_diseases.create( {
        :core_field => CoreField.last,
        :rendered => true
      } )

      @vampirism = create_disease('Vampirism')
      @vampirism.core_fields_diseases.create( {
        :core_field => CoreField.first,
        :rendered => false
      } )
    end

    it "returns true if operation is successful" do
      @lycanthropy.apply_core_fields_to([@vampirism.id]).should be_true
    end

    it "returns false if operation fails" do
      @lycanthropy.apply_core_fields_to(nil).should be_false
    end

    it "copies core fields from the other disease" do
      @lycanthropy.apply_core_fields_to([@vampirism.id]).should be_true
      @lycanthropy.core_fields.should == @vampirism.core_fields
    end

    it "copies rendered status of the field" do
      @lycanthropy.apply_core_fields_to([@vampirism.id]).should be_true
      @vampirism.core_fields_diseases.map(&:rendered).should == [true]
    end
  end

  describe "#add_treatments" do
    before do
      @disease = Factory(:disease)
      @treatment_1 = Factory(:treatment)
      @treatment_2 = Factory(:treatment)
      @treatment_ids = [@treatment_1, @treatment_2].map { |t| t.id.to_s }
    end

    it "adds treatment associations based on an array of treatment ids" do
      @disease.add_treatments(@treatment_ids).should be_true
      @disease.treatments.should == [@treatment_1, @treatment_2]
    end

    it "preserves existing treatment associations" do
      @disease.add_treatments([@treatment_1.id])
      @disease.add_treatments([@treatment_2.id])
      @disease.treatments.should == [@treatment_1, @treatment_2]
    end

    it "does not fail if a treatment id in the array is already associated w/ the disease" do
      @disease.add_treatments([@treatment_1.id])
      @disease.add_treatments(@treatment_ids).should be_true
      @disease.treatments.should == [@treatment_1, @treatment_2]
    end

    it "fails if a treatment id for a non-existent treatment is passed in the array" do
      @disease.add_treatments([-1]).should be_false
    end
  end

  describe "#remove_treatments" do
    before do
      @disease = Factory(:disease)
      @treatment_1 = Factory(:treatment)
      @treatment_2 = Factory(:treatment)
      @disease.treatments << @treatment_1
      @disease.treatments << @treatment_2
    end

    it "removes treatment associations based on an array of treatment ids" do
      @disease.remove_treatments([@treatment_1.id.to_s, @treatment_2.id.to_s]).should be_true
      @disease.treatments.should == []
    end

    it "only deletes associations of treatments w/ ids in the arguments array" do
      @disease.remove_treatments([@treatment_1.id.to_s]).should be_true
      @disease.treatments.should == [@treatment_2]
    end

    it "ignores duplicate ids in the arguments array" do
      @disease.remove_treatments([@treatment_1.id.to_s, @treatment_1.id.to_s]).should be_true
      @disease.treatments.should == [@treatment_2]
    end

    it "ignores ids of treatments that don't exist or aren't associated w/ the disease" do
      @disease.remove_treatments(%w(-1)).should be_true
      @disease.treatments.should == [@treatment_1, @treatment_2]
    end

    it "returns false if removal fails" do
      @disease.remove_treatments(nil).should be_false
    end
  end

  describe "#apply_treatments_to" do
    before do
      @source = Factory(:disease)
      @source.treatments << Factory(:treatment)
      @source.treatments << Factory(:treatment)

      @target_1 = Factory(:disease)
      @target_2 = Factory(:disease)
    end

    it "copies treatments to other diseases, based on an array of disease ids" do
      @source.apply_treatments_to([@target_1.id.to_s, @target_2.id.to_s])
      @target_1.treatments.should == @source.treatments
      @target_2.treatments.should == @source.treatments
    end

    it "replaces the existing treatment configuration of the target disease" do
      @target_1.treatments << Factory(:treatment)
      @source.apply_treatments_to([@target_1.id.to_s])
      @target_1.treatments.should == @source.treatments
    end

    it "should not modify the treatments of the source disease" do
      @source.apply_treatments_to([@source.id.to_s])
      @source.treatments.size.should == 2
    end

    it "returns true if successful" do
      @source.apply_treatments_to([@target_1.id.to_s, @target_2.id.to_s]).should be_true
    end

    it "returns false on failure" do
      @source.apply_treatments_to(nil).should be_false
    end
  end
end

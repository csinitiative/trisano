# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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
  before(:each) do
    @disease = Disease.new(:disease_name => "The Pops")
  end

  it { should have_many(:organisms) }
  it { should have_many(:core_fields_diseases) }
  it { should have_many(:core_fields) }

  it "should be valid" do
    @disease.should be_valid
  end

  it "should not be active" do
    @disease.should_not be_active
  end

  it "can be made active" do
    @disease.active = true
    @disease.save.should be_true
    @disease.should be_active
  end

  it '#find_active should not return inactive diseases' do
    @disease.save.should be_true
    Disease.find(:all).size.should >= 1
    Disease.find_active(:all).size.should == 0
  end

  it '#find_active should return active diseases' do
    @disease.active = true
    @disease.save.should be_true
    Disease.find_active(:all).size.should == 1
  end

  it "should return its live forms" do
    @disease.save.should be_true

    form = Form.new({
        :name => "Test Form",
        :event_type => "morbidity_event",
        :disease_ids => [@disease.id],
        :short_name => 'disease_spec_short'
      }
    )

    form.save_and_initialize_form_elements
    @disease.live_forms.should be_empty
    published_form = form.publish
    published_form.should_not be_nil
    live_forms = @disease.live_forms
    live_forms.should_not be_empty
    live_forms[0].id.should eql(published_form.id)
    live_forms = @disease.live_forms("PlaceEvent")
    live_forms.should be_empty
  end

  describe "loading from a YAML file" do
    fixtures :loinc_codes

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

    it "should default created diseases to active" do
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
      @disease.external_codes.should be_empty
    end

    describe 'associating cases' do

      it 'should add export case status' do
        codes = ExternalCode.find_cases(:all).select {|s| %w(Probable Suspect).include?(s.code_description)}
        codes.length.should == 2
        @disease.update_attributes( 'external_code_ids' => codes.map{|c| c.id} )
        @disease.save!
        @disease.external_codes.length.should == 2
      end
    end

  end

  describe 'diseases w/ no export status' do
    fixtures :diseases, :external_codes, :diseases_external_codes

    it 'should only return diseases with no specified cdc export status' do
      Disease.with_no_export_status.each do |disease|
        disease.external_codes.length.should == 0
      end
    end

  end

  describe 'diseases w/a CDC export code' do

    fixtures :export_columns

    it 'it should create and update corresponding conversion values on save' do
      export_column = ExportColumn.find_by_export_column_name("EVENT")

      @disease.cdc_code = "123456"
      @disease.save.should be_true
      export_conversion_value = ExportConversionValue.find_by_export_column_id_and_value_from(export_column.id, @disease.disease_name)
      export_conversion_value.should_not be_nil
      export_conversion_value.value_to.should eql(@disease.cdc_code)

      @disease.cdc_code = "654321"
      @disease.save.should be_true
      export_conversion_value.reload
      export_conversion_value.value_to.should eql(@disease.cdc_code)

    end
  end

  describe 'export conversion value ids' do
    fixtures :diseases, :export_conversion_values, :export_columns, :diseases_export_columns

    before :each do
      @disease = diseases(:hep_a)
    end

    it 'should ids for export conversion values related to this disease' do
      @disease.export_columns.length.should == 1
      @disease.export_columns[0].export_conversion_values.length.should == 1
      @disease.export_conversion_value_ids.length.should == 1
      @disease.export_conversion_value_ids[0].should == 11
    end

  end

end

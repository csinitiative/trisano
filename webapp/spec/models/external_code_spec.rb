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

describe ExternalCode do
  before(:each) do
    @external_code = ExternalCode.new
  end

  it "should have many diseases with this cdc export status" do
    should have_and_belong_to_many(:cdc_disease_export_statuses)
  end

  it "should be a drop down selection for many diseases" do
    should have_many(:disease_specific_selections)
  end

  it "should be not valid when blank" do
    @external_code.should_not be_valid
  end

  it "should be valid when populated" do
    @external_code.code_name = 'test'
    @external_code.the_code = 'TEST'
    @external_code.code_description = 'Test Code'
    @external_code.should be_valid
    @external_code.save.should be_true
  end

  it "should *not* be disease specific by default" do
    @external_code.disease_specific.should_not be_true
  end

  it "should insert an external code from an array of attribute hashes" do
    hashes = [ { :the_code => 'HOB',
                 :code_description => 'Hobbit',
                 :code_name => 'race' } ]
    lambda do
      ExternalCode.load!(hashes)
    end.should change(ExternalCode, :count).by(1)
  end

  describe 'telephone location type ids' do

    it 'should be able to provide a list of telephone location type ids' do
      ExternalCode.telephone_location_type_ids.should_not be_empty
    end

    it "should only return id codes (which isn't very OO, but there you have it)" do
      result = ExternalCode.telephone_location_type_ids[0].kind_of? Fixnum
      result.should be_true
    end

  end

  describe 'telephone location types' do

    it 'should return all telephone location types in sort order' do
      location_types = ExternalCode.telephone_location_types
      location_types.should_not be_empty
      location_types.first.code_description.should == 'Unknown'
    end

  end

  describe "find codes for autocomplete" do

    before(:each) do
      @code_name = CodeName.find_or_create_by_code_name(:code_name => "eventtype")
      @external_code_1 = ExternalCode.create!(:code_name => "eventtype", :code_description => "ZZAA", :the_code => "ZZAA")
      @external_code_2 = ExternalCode.create!(:code_name => "eventtype", :code_description => "ZZAB", :the_code => "ZZAB")
      @external_code_3 = ExternalCode.create!(:code_name => "eventtype", :code_description => "XXCC", :the_code => "XXCC")
    end

    it "should return all matching codes based on a first letter" do
      codes = ExternalCode.find_codes_for_autocomplete("ZZ")
      codes.size.should eql(2)
      codes[0].is_a?(ExternalCode).should be_true

      codes = ExternalCode.find_codes_for_autocomplete("XX")
      codes.size.should eql(1)
      codes[0].is_a?(ExternalCode).should be_true
    end

    it "should return no codes if there is no match" do
      codes = ExternalCode.find_codes_for_autocomplete("ZZZZZZ")
      codes.size.should eql(0)
    end

    it "should return no codes if nil is provided as a condition" do
      codes = ExternalCode.find_codes_for_autocomplete(nil)
      codes.size.should eql(0)
    end

    it "should limit results based on a provided limit" do
      codes = ExternalCode.find_codes_for_autocomplete("ZZ", 1)
      codes.size.should eql(1)
      codes[0].is_a?(ExternalCode).should be_true
    end

    it "code group for returned code should have user friendly description" do
      codes = ExternalCode.find_codes_for_autocomplete("XX")
      codes.should == [@external_code_3]
      codes.first.code_group.description.should == 'Event Type'
    end
  end

  describe "contact disposition codes" do
    it "should not be nil" do
      code = ExternalCode.find_by_code_name('contactdispositiontype')
      code.should_not be_nil
    end
  end

  describe 'county codes' do
    fixtures :external_codes, :places, :places_types

    it 'should have a related jurisdiction' do
      codes = ExternalCode.find_all_by_code_name('county')
      codes.size.should == 3
      codes.each do |county|
        county.jurisdiction.should_not be_nil if county.the_code != "OS"
      end
    end
  end

  describe 'find cases' do
    fixtures :external_codes

    it 'should return only cases w/ :all' do
      codes = ExternalCode.find_cases(:all)
      codes.size.should == 8
      codes.each {|code| code.code_name.should == 'case'}
    end
  end

  describe 'find loinc scales' do
    fixtures :external_codes

    it 'should find loinc scales by the code' do
      ExternalCode.loinc_scale_by_the_code('Ord').should == external_codes(:loinc_scale_ord)
    end

    it 'should return nil if loinc scale not in the db' do
      ExternalCode.loinc_scale_by_the_code('Doc').should be_nil
    end
  end

  describe "disease specific selections" do
    before do
      @code_selection = external_code!('yesno', 'M', :disease_specific => true)
      @disease = disease!('Dengue')
      @event = Factory.create(:morbidity_event)
      @event.build_disease_event(:disease => @disease).save!
      @association = @disease.disease_specific_selections.create(:external_code => @code_selection, :rendered => true)
    end

    it "should be rendered if associated disease is the current disease" do
      @code_selection.should be_rendered(@event)
    end

    it "should not be rendered if associated disease is not the current disease" do
      @event.disease_event.update_attributes!(:disease => disease!('The Trots'))
      @code_selection.should_not be_rendered(@event)
    end

    it "should not be rendered if there is no current disease" do
      @event.update_attributes!(:disease_event => nil)
      @code_selection.should_not be_rendered(@event)
    end

    it "should not be rendered if there is no associated disease" do
      @association.destroy
      @code_selection.should_not be_rendered(@event)
    end
  end

  describe "'core' selections" do
    before do
      @code_selection = external_code!('yesno', 'Y')
      @disease = disease!('Dengue')
      @event = Factory.create(:morbidity_event)
      @event.build_disease_event(:disease => @disease).save!
      @association = @disease.disease_specific_selections.build(:external_code => @code_selection, :rendered => false)
      @association.save!
    end

    it "should be rendered if there is no associated disease" do
      @association.destroy
      @code_selection.should be_rendered(@event)
    end

    it "should be rendered if there is no current disease" do
      @event.update_attributes!(:disease_event => nil)
      @code_selection.should be_rendered(@event)
    end

    it "should be rendered if the associated disease is not the current disease" do
      @event.disease_event.update_attributes!(:disease => disease!('The Trots'))
      @code_selection.should be_rendered(@event)
    end

    it "should not be rendered if the associated disease is the current disease" do
      @code_selection.should_not be_rendered(@event)
    end
  end
end

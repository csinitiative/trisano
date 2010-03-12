# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

describe Export::Csv do
  include CsvSpecHelper

  before :all do
    file = File.join(File.dirname(__FILE__), '../../db/defaults/csv_fields.yml')
    CsvField.load_csv_fields(YAML.load_file(file))
  end

  after(:all) { CsvField.destroy_all }

  before(:each) do
    @event_hash = {
      :interested_party_attributes => {
        :person_entity_attributes => {
          :person_attributes => {
            :last_name =>"Green"
          }
        }
      }
    }
    # There are 7 races
    ExternalCode.stubs(:count).returns(7)
  end

  it "should expose an export method that takes an event or a list of events and an optional proc" do
    lambda { Export::Csv.export(   MorbidityEvent.create(@event_hash)   )    }.should_not raise_error()
    lambda { Export::Csv.export( [ MorbidityEvent.create(@event_hash) ] )    }.should_not raise_error()
    lambda { Export::Csv.export( [ MorbidityEvent.create(@event_hash) ] ) { MorbidityEvent.create(@event_hash) } }.should_not raise_error()

    lambda { Export::Csv.export( Object.new) }.should raise_error(ArgumentError)
  end

  describe "when passed a single simple event" do
    it "should output event, contact, place, treatment, and lab result HEADERS on one line" do
      to_arry( Export::Csv.export( MorbidityEvent.create(@event_hash), :export_options => %w(labs treatments places contacts) ) ).first.should == event_header(:morbidity) + "," + lab_header + "," + treatment_header + "," + event_header(:place) + "," + event_header(:contact)
    end

    it "should output content for a simple event" do
      a = to_arry( Export::Csv.export( MorbidityEvent.create(@event_hash) ) )
      a.size.should == 2
      a[1].include?(@event_hash[:interested_party_attributes][:person_entity_attributes][:person_attributes][:last_name]).should be_true
    end
  end

  describe "when passed multiple simple events" do
    it "should iterate over each event" do
      second_person = "White"
      deleted_person = 'Gone'
      eh = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => second_person } } } }
      dh = { :interested_party_attributes => { :person_entity_attributes => { :person_attributes => { :last_name => deleted_person } } }, :deleted_at => DateTime.parse('2008-01-01T12:00:00')}

      e1 = MorbidityEvent.create(@event_hash)
      e2 = MorbidityEvent.create( eh )
      e3 = MorbidityEvent.create( dh )

      a = to_arry( Export::Csv.export( [e1, e3, e2] ) )
      a.size.should == 3
      a[1].include?(@event_hash[:interested_party_attributes][:person_entity_attributes][:person_attributes][:last_name]).should be_true
      a[2].include?(second_person).should be_true
    end
  end

  # Debt: Does not yet test places
  describe "when passed a complex (fully loaded) event" do
    it "should output the right information" do
      e = csv_mock_event(:morbidity)
      a = to_arry( Export::Csv.export( e, {:export_options => ["labs", "treatments"], :disease => csv_mock_disease } ) )
      a[0].include?("disease_specific_morb_q").should be_true
      a[1].should == "#{event_output(:morbidity, e, {:disease => csv_mock_disease}) + "," + lab_output + "," + treatment_output}"
    end
  end

  describe "when passed an event w/ a contact" do
    before do
      @morbidity_event = Factory.create(:morbidity_event)
      @contact_event   = Factory.create(:contact_event)
      @contact_event.parent_event = @morbidity_event
      @contact_event.save!
    end

    it "should output the contact" do
      result = to_arry(Export::Csv.export(@morbidity_event, :export_options => %w(contacts)))
      assert_values_in_result(result, :contact_disease => /The dreaded lurgy (\d+)/i)
    end

    describe "and when contact promoted to cmr" do
      before do
        login_as_super_user
        @contact_event.promote_to_morbidity_event.should be_true
      end

      it "should still output contact" do
        result = to_arry(Export::Csv.export(@morbidity_event, :export_options => %w(contacts)))
        assert_values_in_result(result, :contact_disease => /The dreaded lurgy (\d+)/i)
      end
    end
  end


  describe 'picking codes over descriptions' do
    before(:each) do
      @county = Factory.build(:external_code)
      @county.stubs(:jurisdiction).returns(nil)
      @address = Factory.build(:address)
      @address.attributes = {
        :street_number => nil,
        :street_name => nil,
        :unit_number => nil,
        :city => nil,
        :state => nil,
        :county => @county,
        :postal_code => nil
      }
      @event = Factory.create(:morbidity_event)
    end

    it 'should return county code, not name' do
      @event.stubs(:address).returns(@address)
      @county.expects(:the_code).returns('56')
      Export::Csv.export(@event, {'patient_address_county' => 'use_code'})
    end

    it 'should pick cdc code, rather then disease name' do
      d = Factory.build(:disease)
      d.expects(:cdc_code).returns('10110')
      de = Factory.build(:disease_event)
      @event.stubs(:disease_event).returns(de)
      de.expects(:disease).returns(d)
      Export::Csv.export(@event, {'patient_disease' => 'use_code'})
    end
  end

end


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

describe CoreField do
  before :all do
    CoreField.delete_all  # There's been fixutures spotted around these parts.
  end

  after :all do
    Fixtures.reset_cache
  end

  before :each do
    @core_field = CoreField.create(:key => 'morbidity_event[test_field]', :event_type => 'morbidity_event')
  end

  after { I18n.locale = :en }

  it "should update help test" do
    @core_field.help_text = 'Here is some help text'
    @core_field.save.should be_true
    CoreField.find_by_key(@core_field.key).help_text.should == 'Here is some help text'
  end

  it 'should provide hashes based on event type' do
    CoreField.event_fields('morbidity_event').size.should == 1
    CoreField.event_fields('contact_event').size.should == 0
    CoreField.event_fields('place_event').size.should == 0
  end

  it 'should provide hashes based on event' do
    CoreField.event_fields(MorbidityEvent.new).size.should == 1
  end

  it 'should return fields based on key' do
    hash = CoreField.event_fields('morbidity_event')
    hash['morbidity_event[test_field]'].should_not be_nil
  end

  it "should memoize fields for rendering" do
    hash = CoreField.event_fields('morbidity_event')
    hash['morbidity_event[test_field]'][:help_text].should be_blank
    CoreField.update_all("help_text='some help text'", ['key=?', 'morbidity_event[test_field]'])
    CoreField.event_fields('morbidity_event')['morbidity_event[test_field]'][:help_text].should be_blank
    CoreField.flush_memoization_cache
    CoreField.event_fields('morbidity_event')['morbidity_event[test_field]'][:help_text].should == 'some help text'
  end

  it "event_fields should return hash of core fields" do
    hash = CoreField.event_fields('morbidity_event')
    hash['morbidity_event[test_field]'].class.should == CoreField
  end

  it "should pull english translations for name" do
    I18n.locale = :en
    cf = CoreField.create!(:key => 'morbidity_event[places]', :event_type => 'morbidity_event')
    cf.name.should == 'Places'
  end

  it "should return scope for I18n retrieval" do
    cf = CoreField.create!(:key => 'morbidity_event[places]', :event_type => 'morbidity_event')
    cf.i18n_scope.should == ['event_fields', 'morbidity_event']
  end

  it "should return the name key for i18n retrieval" do
    cf = CoreField.create!(:key => 'morbidity_event[places]', :event_type => 'morbidity_event')
    cf.name_key.should == 'places'
  end
end

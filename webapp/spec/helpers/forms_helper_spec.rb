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
require RAILS_ROOT + '/app/helpers/application_helper'

describe FormsHelper do
  include HtmlSpecHelper

  # Debt: setting up these tests needs to be easier
  before do
    @core_field = CoreField.create!(:key => 'morbidity_event[places]', :event_type => 'morbidity_event')
    @form = Factory.build(:form, :event_type => 'morbidity_event')
    @form.save_and_initialize_form_elements
    @core_field_element = Factory.build(:core_field_element, :core_path => 'morbidity_event[places]')
    @core_field_element.form = @form
    @core_field_element.parent_element_id = @form.form_base_element.id
    @core_field_element.save_and_add_to_form
    @core_field_element.save!
  end

  describe "event field" do
    it "should return a core field" do
      helper.event_field(@core_field_element).should == @core_field
    end
  end

  describe "rendering for field" do
    it "should render the core field's name" do
      helper.render_core_field(nil, @core_field_element, false).should =~ /places/i
    end
  end

  describe "rendering follow ups" do
    it "should render core field's name" do
      helper.render_follow_up(nil, @core_field_element, false).should =~ /places/i
    end
  end

  describe "follow up (core path) select" do
    before do
      fu_field = CoreField.create!({
        :key => 'morbidity_event[other_data_1]',
        :event_type => 'morbidity_event',
        :can_follow_up => true})
      fu_field.clone.update_attributes!(:key => 'morbidity_event[acuity]')
    end

    it "should have only follow up fields" do
      options = helper.follow_up_select_options(:morbidity_event)
      options.should == [['Acuity', 'morbidity_event[acuity]'],
                         ['Other Data (First Field)', 'morbidity_event[other_data_1]']]
    end
  end

  describe "event type options" do
    before do
      options = helper.form_event_type_options_for_select(@form)
      @element = parse_html(options)
    end

    it "should include Morbidity Event" do
      @element.css('option[value="morbidity_event"]').text.should == 'Morbidity Event'
    end

    it "should include Contact Event" do
      @element.css('option[value="contact_event"]').text.should == 'Contact Event'
    end

    it "should include Place Event" do
      @element.css('option[value="place_event"]').text.should == 'Place Event'
    end

    it "should include Encounter Event" do
      @element.css('option[value="encounter_event"]').text.should == 'Encounter Event'
    end

    it "should select the morbidity event" do
      @element.css('option[selected]').text.should == 'Morbidity Event'
    end

  end
end

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

describe MorbidityEventsHelper do
  include EventsSpecHelper
  include DiseaseSpecHelper
  include CoreFieldSpecHelper

  describe "tabs helper" do
    before do
      given_cmr_core_tabs_loaded
    end

    it 'should include all morbidity event core tabs' do
      tabs = helper.morbidity_event_tabs
      tabs.size.should == 10
      helper.morbidity_event_tabs.find { |tab| tab[0] == "demographic_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "clinical_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "lab_info_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "contacts_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "encounters_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "epi_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "reporting_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "investigation_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "notes_tab"  }.should_not be_nil
      helper.morbidity_event_tabs.find { |tab| tab[0] == "administrative_tab"  }.should_not be_nil
    end

    it "only shows tabs enabled on the current event" do
      disease = given_a_disease_named('The Trots')
      assigns[:event] = given_a_morb_with_disease disease
      hide_morbidity_event_tabs(:lab_info_tab, :contacts_tab, :encounters_tab, :investigation_tab, :on_disease => disease)
      helper.morbidity_event_tabs.map(&:first).should == %w(demographic_tab clinical_tab epi_tab reporting_tab notes_tab administrative_tab)
    end
  end

end

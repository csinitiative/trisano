# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

describe ContactEventsHelper do

  describe "tabs helper" do
    before do
      given_contact_core_tabs_loaded
      helper.class_eval { include EventsHelper }
    end

    it 'should include all contact event core tabs' do
      helper.contact_event_tabs.map(&:name_key).should == %w(demographic_tab clinical_tab lab_info_tab epi_tab investigation_tab notes_tab)
    end

    it "only shows tabs enabled on the current event" do
      disease = create_disease('The Trots')
      assigns[:event] = create_contact_event(:disease => disease)
      hide_contact_event_tabs(:lab_info_tab, :investigation_tab, :on_disease => disease)
      helper.contact_event_tabs.map(&:name_key).should == %w(demographic_tab clinical_tab epi_tab notes_tab)
    end
  end

end

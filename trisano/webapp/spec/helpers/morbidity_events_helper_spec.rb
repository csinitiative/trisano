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

describe MorbidityEventsHelper do

  describe "tabs helper" do
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
  end
    
end

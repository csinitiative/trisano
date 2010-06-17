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

require File.expand_path(File.dirname(__FILE__) +  '/../../../../../spec/spec_helper')

describe Export::Csv do
  include PerinatalHepBSpecHelper

  before :all do
    file = File.join(File.dirname(__FILE__), '../../../trisano_en/config/misc/en_csv_fields.yml')
    CsvField.load_csv_fields(YAML.load_file(file))
  end

  after(:all) { CsvField.destroy_all }

  before(:each) do
    @event = human_event_with_demographic_info!(
      :morbidity_event,
      :last_name => "Johnson"
    )

    @expected_delivery_facility = add_expected_delivery_facility_to_event(@event,
      "Allen Hospital",
      :expected_delivery_date => Date.today + 15
    )
  end

  it "should expected delivery facility information in CSV export" do
    @event.expected_delivery_facility.nil?.should be_false
  end
  
end


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
require 'spec_helper'

describe "/events/_clinical_show_print.html.haml" do

  context "printing disagnostic facilities" do
    let(:event) { Factory.create(:morbidity_event) }

    before do
      mock_user
      assigns[:event] = event
      assigns[:print_options] = [I18n.t('clinical')]
      @facility = Factory.create(:diagnostic_facility)
      event.diagnostic_facilities << @facility
      render "/morbidity_events/show.print.haml"
      @printed_values = Nokogiri::HTML(response.body).css(".print-value").text.map(&:strip).join("\n")
    end

    it "should show place name" do
      @printed_values[@facility.place_entity.place.name].should == @facility.place_entity.place.name
    end

    it "should show place address" do
      address = @facility.place_entity.canonical_address.preferred_format
      @printed_values[address].should == address
    end

    it "should show place type" do
      type = @facility.place_entity.place.formatted_place_descriptions
      @printed_values[type].should == type
    end
  end
end

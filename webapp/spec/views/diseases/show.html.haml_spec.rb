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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/diseases/show.html.haml" do
  include DiseasesHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @export_column_1 = mock_model(ExportColumn)
    @export_column_1.stub!(:export_column_name).and_return("CHLOR")
    @export_column_2 = mock_model(ExportColumn)
    @export_column_2.stub!(:export_column_name).and_return("DAYCARE")
    @disease.stub!(:disease_name).and_return("The Pops")
    @disease.stub!(:active?).and_return(true)
    @disease.stub!(:cdc_code).and_return("123456")
    @disease.stub!(:export_columns).and_return([@export_column_1, @export_column_2])
    @disease.stub!(:external_codes).and_return([])
    @disease.stub!(:contact_lead_in).and_return("")
    @disease.stub!(:place_lead_in).and_return("")
    @disease.stub!(:treatment_lead_in).and_return("")
    assigns[:disease] = @disease
  end

  it "should show the export column mappings" do
    render "/diseases/show.html.haml"
    response.should have_tag('li', :text => 'CHLOR')
    response.should have_tag('li', :text => 'DAYCARE')
  end
  

end


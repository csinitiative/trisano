# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

describe "/diseases/new.html.haml" do
  include DiseasesHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @disease.stub!(:new_record?).and_return(true)
    @disease.stub!(:disease_name).and_return("The Pops")
    @disease.stub!(:contact_lead_in).and_return("")
    @disease.stub!(:place_lead_in).and_return("")
    @disease.stub!(:treatment_lead_in).and_return("")
    @disease.should_receive(:active).and_return(true)
    @disease.should_receive(:cdc_code).and_return("")
    assigns[:disease] = @disease
  end

  it "should render new form" do
    render "/diseases/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", diseases_path) do
    end
  end
end



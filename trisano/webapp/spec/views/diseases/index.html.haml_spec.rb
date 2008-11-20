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

describe "/diseases/index.html.haml" do
  include DiseasesHelper
  
  before(:each) do
    disease_98 = mock_model(Disease)
    disease_98.stub!(:disease_name).and_return("The Pops")
    disease_98.should_receive(:active?).and_return(true)
    disease_98.stub!(:cdc_code).and_return("123456")
    
    disease_99 = mock_model(Disease)
    disease_99.stub!(:disease_name).and_return("The Pops")
    disease_99.should_receive(:active?).and_return(true)
    disease_99.stub!(:cdc_code).and_return("654321")

    assigns[:diseases] = [disease_98, disease_99]
  end

  it "should render list of diseases" do
    render "/diseases/index.html.haml"
  end
end


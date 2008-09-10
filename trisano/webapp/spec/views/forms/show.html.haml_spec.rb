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

describe "/forms/show.html.haml" do
  include FormsHelper
  
  before(:each) do
    @disease = mock_model(Disease)
    @disease.stub!(:disease_name).and_return("Anthrax")

    @place = mock_model(Place)
    @place.stub!(:name).and_return("Davis")
    @entity = mock_model(Entity)
    @entity.stub!(:current_place).and_return(@place)

    @form = mock_model(Form)
    @form.stub!(:name).and_return("Anthrax Form")
    @form.stub!(:description).and_return("Questions to ask when disease is Anthrax")
    @form.stub!(:diseases).and_return([@disease])
    @form.stub!(:jurisdiction).and_return(@entity)
    @form.stub!(:status).and_return('Not Published')
    @form.stub!(:event_type).and_return('morbidity_event')
    
    assigns[:form] = @form
  end

  it "should render attributes in <p>" do
    render "/forms/show.html.haml"
    response.should have_text(/Anthrax Form/)
    response.should have_text(/Questions to ask when disease is Anthrax/)
    response.should have_text(/Anthrax/)
    response.should have_text(/Davis/)
  end
end

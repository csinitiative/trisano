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

# We should merge edit and new commonalities
describe "/forms/edit.html.haml" do
  include FormsHelper
  
  before do
    @form = mock_model(Form)
    @form.stub!(:name).and_return("MyString")
    @form.stub!(:description).and_return("MyString")
    @form.stub!(:disease_id).and_return(1)
    @form.stub!(:jurisdiction_id).and_return(2)
    @form.stub!(:event_type).and_return('morbidity_event')
    @form.stub!(:is_template).and_return(true)
    @form.stub!(:jurisdiction).and_return(nil)
    @form.stub!(:status).and_return("Published")
    
    @disease_1 = mock_model(Disease)
    @disease_1.stub!(:disease_name).and_return("Anthrax")
    @disease_2 = mock_model(Disease)
    @disease_2.stub!(:disease_name).and_return("Tetanus")
    Disease.should_receive(:find).and_return([@disease_1, @disease_2])

    @form.stub!(:diseases).and_return([@disease_1])

    @jurisdiction_1 = mock_model(Place)
    @jurisdiction_1.stub!(:name).and_return("Summit")
    @jurisdiction_1.stub!(:entity_id).and_return("1")
    @jurisdiction_2 = mock_model(Place)
    @jurisdiction_2.stub!(:name).and_return("Davis")
    @jurisdiction_2.stub!(:entity_id).and_return("2")
    Place.should_receive(:jurisdictions).and_return([@jurisdiction_1, @jurisdiction_2])

    assigns[:form] = @form
  end

  it "should render edit form" do
    render "/forms/edit.html.haml"
    
    response.should have_tag("form[action=#{form_path(@form)}][method=post]") do
      with_tag('input#form_name[name=?]', "form[name]")
      with_tag('input#form_description[name=?]', "form[description]")
      with_tag("input[type=checkbox]", 2) 
      with_tag("select#form_jurisdiction_id[name=?]", "form[jurisdiction_id]") do
        with_tag("option", "Summit")
        with_tag("option", "Davis")
      end

    response.should have_text(/Anthrax/)
    response.should have_text(/Tetanus/)
    end
  end
end



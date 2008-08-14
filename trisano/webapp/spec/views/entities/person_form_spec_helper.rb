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

module PersonFormSpecHelper
  describe "a person form", :shared => true do
    fixtures :codes, :external_codes

    before(:each) do
      @entity = mock_person_entity
      @event = mock_event
      @event.stub!(:under_investigation?).and_return(false)
      @event.stub!(:reopened?).and_return(false)
      
      
      assigns[:entity] = @entity
      assigns[:type] = 'person'
      assigns[:event] = @event
    end
  
    it "should render the form elements" do
      do_render

      response.should have_tag("form") do
        with_tag("input#entity_person_last_name[name=?]", "entity[person][last_name]")
        with_tag('input#entity_person_first_name[name=?]', "entity[person][first_name]")
#        with_tag('input#entity_person_middle_name[name=?]', "entity[person][middle_name]")
        with_tag('select#entity_person_birth_gender_id[name=?]', "entity[person][birth_gender_id]") do
          with_tag('option', 'Male')
          with_tag('option', 'Female')
          with_tag('option', 'Unknown')
        end
        with_tag('select#entity_person_ethnicity_id[name=?]', "entity[person][ethnicity_id]") do
          with_tag('option', 'Hispanic or Latino')
          with_tag('option', 'Not Hispanic or Latino')
          with_tag('option', 'Other')
          with_tag('option', 'Unknown')
        end
        with_tag('select#entity_race_ids[name=?]', "entity[race_ids][]") do
          with_tag('option', 'White')
          with_tag('option', 'Black / African-American')
          with_tag('option', 'Asian')
          with_tag('option', 'American Indian')
          with_tag('option', 'Alaskan Native')
          with_tag('option', 'Native Hawaiian / Pacific Islander')
        end
        with_tag('select#entity_person_primary_language_id[name=?]', "entity[person][primary_language_id]") do
          with_tag('option', 'English')
          with_tag('option', 'Spanish')
        end
        with_tag('input#entity_person_birth_date[name=?]', "entity[person][birth_date]")
#        with_tag('input#entity_person_date_of_death[name=?]', "entity[person][date_of_death]")
      end
    end
  end
end

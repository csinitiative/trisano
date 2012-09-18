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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/question_elements/process_condition.rjs" do

  before do
    @form = Factory.build(:form)
    @form.save_and_initialize_form_elements

    @question_element = Factory.build(:question_element, {
                                        :parent_element_id => @form.investigator_view_elements_container.id } )
    @question_element.save_and_add_to_form

    @follow_up = Factory.build(:follow_up_element, {
                                 :parent_element_id => @question_element.id } )
    @follow_ups = [@follow_up]
    @follow_up.save_and_add_to_form

    assigns[:follow_up] = @follow_up
    assigns[:follow_ups] = @follow_ups
    assigns[:question_element_id] = @question_element.id
  end

  it "renders" do
    render "question_elements/process_condition.rjs"
  end

end

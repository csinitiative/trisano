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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/follow_up_elements/process_core_condition.rjs" do

  before do
    @form = Factory.build(:form)
    @form.save_and_initialize_form_elements

    @q = Factory.build(:question_element, {
                         :parent_element_id => @form.core_view_elements_container.id })
    @q.save_and_add_to_form

    @fu = Factory.build(:follow_up_element, {
                          :parent_element_id => @q.id })
    @fu.save_and_add_to_form
  end

  it "renders, showing the partial" do
    assigns[:follow_ups] = [["show", @fu]]
    render "follow_up_elements/process_core_condition.rjs"
  end

  it "renders, hiding the partial" do
    assigns[:follow_ups] = [["hide", @fu]]
    render "follow_up_elements/process_core_condition.rjs"
  end
end

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

require File.dirname(__FILE__) + '/../../spec_helper'

describe "/question_elements/_form.html.haml" do

  before do
    @form = Factory.build(:form)
    @form.save_and_initialize_form_elements

    @question_element = Factory.build(:question_element, {
        :parent_element_id => @form.investigator_view_elements_container.id } )
    @question_element.save_and_add_to_form

    @f = mock
    @f.expects(:hidden_field).with(:parent_element_id)
    @q = mock
    @q.expects(:hidden_field).with(:core_data)
    @q.expects(:label).with(:question_text)
    @q.expects(:text_field).with(:question_text)
    @q.expects(:label).with(:short_name)
    @q.stubs(:object).returns(@question_element.question)
    @q.expects(:text_field).with(:short_name)
    @f.expects(:label).with(:is_active)
    @f.expects(:radio_button).with(:is_active, "true")
    @f.expects(:radio_button).with(:is_active, "false")
    @q.expects(:label).with(:style)
    @q.expects(:select).with(:style, [['Horizontal', 'horiz'], ['Vertical', 'vert']], {:include_blank => true})
    @q.expects(:label).with(:help_text)
    @q.expects(:text_area).with(:help_text, :rows => 10)
    @f.expects(:fields_for).with(:question).yields(@q)
  end

  it "renders" do
    render "question_elements/_form.html.haml", :locals => { :f => @f }
  end

end

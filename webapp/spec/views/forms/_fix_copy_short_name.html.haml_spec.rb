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

describe "/forms/_fix_copy_short_name.html.haml" do

  before do
    @form_element = Factory.build(:form_element)
    @lib_element  = Factory.build(:question_element)
    @lib_element.question.stubs(:collision).returns(nil)
    assigns[:form_element] = @form_element
    assigns[:lib_element]  = @lib_element
    assigns[:compare_results] = [@lib_element.question]
  end

  it "should render question short names" do
    render "forms/_fix_copy_short_name.html.haml"
    response.should have_tag("input[id=?][name=?]",
                             "replacements_#{@lib_element.question.id}_short_name",
                             "replacements[#{@lib_element.question.id}][short_name]")
  end

  it "renders field as an error if question has a collision" do
    @lib_element.question.stubs(:collision).returns("t")
    render "forms/_fix_copy_short_name.html.haml"
    response.should have_tag("div[class=?]", "fieldWithErrors") do
      with_tag("input[id=?][name=?]",
               "replacements_#{@lib_element.question.id}_short_name",
               "replacements[#{@lib_element.question.id}][short_name]")
    end
  end

end

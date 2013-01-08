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

require File.dirname(__FILE__) + '/../spec_helper'

describe Questions do
  fixtures :forms, :form_elements, :questions

  describe "managing short names within a form" do

    it 'should instaniate from a Form' do
      form = Form.new
      form.questions << Question.new
      Questions.from_form(form).size.should == 1
    end

    it 'should only update questions scoped to the current form' do
      form = forms(:test_form)
      questions = Questions.from_form(form)
      not_on_form = questions(:hep_non_cdc_q)
      on_form     = questions(:demo_q1)
      questions.update(not_on_form.id.to_s => {:short_name => 'new_short_name_not_on_form'},
                       on_form.id.to_s     => {:short_name => 'new_short_name_on_form'})
      Question.find(not_on_form.id).short_name.should_not == 'new_short_name_not_on_form'
      Question.find(on_form.id).short_name.should == 'new_short_name_on_form'
    end

    it 'update should gracefully handle a nil questions hash' do
      form = forms(:test_form)
      questions = Questions.from_form(form)
      questions.update(nil).should be_true
    end

  end

end

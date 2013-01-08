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

class ValueElement < FormElement
  belongs_to :export_conversion_value

  validates_presence_of(:name,
                        :if => :radio_button_question?,
                        :message => I18n.t(:radio_button_blank_value,
                                           :scope => [:form_errors]))
  validates_presence_of(:name,
                        :if => :check_box_question?,
                        :message => I18n.t(:check_box_blank_value,
                                           :scope => [:form_errors]))

  def radio_button_question?
    return false unless question
    question.data_type == :radio_button
  end

  def check_box_question?
    return false unless question
    question.data_type == :check_box
  end

  # we need to get the question this way because:
  #     1. it's faster. fewer trips to the database
  #     2. we can't walk parents at the point validation is called
  #     because of how form elements are added to forms.
  def question
    @question ||= Question.first(:joins => ['join form_elements a ON questions.form_element_id = a.id',
                                            'join form_elements b ON b.parent_id = a.id'],
                                 :conditions => ['b.id = ?', parent_element_id])
  end

  def question=(question)
    @question = question
  end

  def copy(options = {})
    return unless valid?
    super
  end
end

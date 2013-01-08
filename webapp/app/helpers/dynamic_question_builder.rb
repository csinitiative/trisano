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
class DynamicQuestionBuilder

  def initialize(options={})
    @question_element = options.fetch(:question_element)
    @form_elements_cache = options.fetch(:form_elements_cache)
  end

  def question_is_multi_valued_and_has_no_value_set?
    question.is_multi_valued? && 
    !@form_elements_cache.has_value_set_for?(@question_element)
  end   


  private

  def question
    @question_element.question
  end
end

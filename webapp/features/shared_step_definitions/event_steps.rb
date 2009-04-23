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

Given(/^a (.+) event exists with the disease (.+)$/) do |event_type, disease|
  @event = create_basic_event(event_type, get_unique_name(1), disease, get_random_jurisdiction_by_short_name)
end

Given(/^a (.+) event exists in (.+) with the disease (.+)$/) do |event_type, jurisdiction, disease|
  @event = create_basic_event(event_type, get_unique_name(1), disease, jurisdiction)
end

Given(/^the forms for the event have been assigned$/) do
  @event.create_form_references
end

Given(/^the disease-specific questions for the event have been answered$/) do
  @answer_text = "#{get_unique_name(2)} answer"
  question_elements = FormElement.find_all_by_form_id_and_type(@published_form.id, "QuestionElement", :include => [:question])
  question_elements.each do |element|
    Answer.create({ :event_id => @event.id, :question_id => element.question.id, :text_answer => @answer_text })
  end
  
end
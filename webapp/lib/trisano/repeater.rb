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
module Trisano::Repeater
  def self.included(base)
    base.class_eval do
      has_many :answers, :include => [:question], 
                         :as => :repeater_form_object, 
                         :autosave => true,
                         :dependent => :destroy
    end
  end

  def repeater_answers=(attributes)
    if answers.empty?
      answers.build(attributes.values)
    else
      answers.each { |answer| answer.attributes = attributes[answer.id.to_s] }
    end
  end

  def new_repeater_answers=(attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    answers = self.answers.build(attributes)
    answers.each { |answer| answer.repeater_form_object = self }
  end


  def new_repeater_checkboxes=(attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    attributes.each do |attribute_hash|
      attribute_hash.each do |question_id, answer_attributes|
        answer = self.answers.build(
          :question_id => question_id,
          :check_box_answer => answer_attributes[:check_box_answer],
          :code => answer_attributes[:code],
          :event_id => answer_attributes[:event_id]
        )
        answer.repeater_form_object = self
      end
    end
  end

  def new_repeater_radio_buttons=(attributes)
    attributes = [attributes] unless attributes.is_a?(Array)
    attributes.each do |attribute_hash|
      attribute_hash.each do |question_id, answer_attributes|
        answer = self.answers.build(
          :question_id => question_id,
          :radio_button_answer => answer_attributes[:radio_button_answer],
          :export_conversion_value_id => answer_attributes[:export_conversion_value_id],
          :code => answer_attributes[:code],
          :event_id => answer_attributes[:event_id]
        )
        answer.repeater_form_object = self
      end
    end
  end
end

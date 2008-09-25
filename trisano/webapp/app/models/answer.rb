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

class Answer < ActiveRecord::Base
  belongs_to :question

  validates_length_of   :text_answer, :maximum => 2000, :allow_blank => true
  validates_presence_of :text_answer, :if => :required
  validates_format_of :text_answer, :with => /^\d{3}-\d{3}-\d{4}$/, :message => 'Phone number must include area code and seven digit number', :allow_blank => true, :if => :is_phone
  validates_date :date_answer, :if => :is_date, :allow_nil => true

  def date_answer
    ActiveRecord::ConnectionAdapters::Column.send("string_to_date", text_answer)
  end

  def date_answer_before_type_cast
    text_answer
  end

  def check_box_answer=(answer)
    self.text_answer = answer.join("\n")
  end

  def check_box_answer
    self.text_answer.nil? ? [] : self.text_answer.split("\n")
  end

  def radio_button_answer=(answer)
    answer = answer.reject {|item| item.blank? } if answer.size > 1
    self.text_answer = answer.join("\n")
  end

  def radio_button_answer
    self.text_answer.nil? ? [] : self.text_answer.split("\n")
  end

  def required
    question.is_required
  end

  def is_date
    question.data_type == :date
  end

  def is_phone
    question.data_type == :phone
  end

  def before_validation
    if question.data_type == :phone
      phone = text_answer.gsub(/[^0-9]/, '')
      if phone.length == 10
        phone = phone.insert(3, "-")
        self.text_answer = phone.insert(7, "-")
      end
    end
  end

  def short_name
    question.short_name unless question.nil? || question.short_name.blank?
  end
end

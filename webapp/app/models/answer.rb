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

class Answer < ActiveRecord::Base
  include Export::Cdc::CdcWriter

  belongs_to :question
  belongs_to :export_conversion_value

  class << self
    def regexp(field)
      Regexp.compile(answer_options[field] || '')
    end

    def answer_options
      (@answer_options ||= config_options[:answer]).with_indifferent_access
    end

    def answer_options=(options)
      @answer_options = options
    end
  end

  validates_length_of   :text_answer, :maximum => 2000, :allow_blank => true
  validates_presence_of :text_answer, :if => :required
  validates_format_of :text_answer, :with => regexp(:phone), :allow_blank => true, :if => :is_phone
  validates_date :date_answer, :if => :is_date, :allow_blank => true

  def self.export_answers(*args)
    args = [:all] if args.empty?
    with_scope(:find => {:conditions => ['export_conversion_value_id is not null']}) do
      find(*args)
    end
  end

  # modifies result string based on export conversion
  # rules. Result is lengthened if needed. Returns the value that
  # was inserted.
  def write_export_conversion_to(result)
    write(convert_value(self.text_answer, export_conversion_value), 
          :starting => export_conversion_value.export_column.start_position - 1, 
          :length => export_conversion_value.export_column.length_to_output,
          :result => result)
  end

  def date_answer
    ValidatesTimeliness::Parser.parse(text_answer, :date)
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

  def before_save
    if self.is_date and !self.blank?
      self.text_answer = date_answer.to_s
    end

    set_answer_code
  end

  def short_name
    question.short_name unless question.nil? || question.short_name.blank?
  end

  private

  def set_answer_code
    if (question.is_multi_valued? && question.question_element.export_column_id.blank?)
      begin
        if question.data_type == :check_box
          self.code = concat_checkbox_codes
        else
          self.code = question.question_element.value_set_element.value_elements.find_by_name(text_answer).code
        end
      rescue Exception => ex
        # Nothing above should cause an exception, unless the form structure is off, in which case this code probably wouldn't even run. Just log a warning.
        logger.warn ex
      end
    end
  end

  def concat_checkbox_codes
    codes = []

    self.text_answer.split("\n").each do |check_box_value|
      codes << question.question_element.value_set_element.value_elements.find_by_name(check_box_value).code
    end

    codes.join("\n")
  end

end

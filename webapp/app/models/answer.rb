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

class Answer < ActiveRecord::Base
  include Export::Cdc::CdcWriter

  belongs_to :question
  belongs_to :export_conversion_value
  belongs_to :repeater_form_object, :polymorphic => true
  belongs_to :event

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

  validates_uniqueness_of :question_id, :scope => [:event_id, :repeater_form_object_id, :repeater_form_object_type]
  validates_length_of   :text_answer, :maximum => 2000, :allow_blank => true
  validates_presence_of :text_answer, :if => :required, :message => "^There are unanswered required questions."
  validates_format_of :text_answer, :with => regexp(:phone), :allow_blank => true, :if => :is_phone
  validates_format_of :text_answer, :with => regexp(:numeric), :allow_blank => true, :if => :numeric_question, :message => "accepts only positive or negative integers (0-9) and one optional decimal point"
  validate :numeric_min, :if => :numeric_min_set
  validate :numeric_max, :if => :numeric_max_set
  validates_date :date_answer, :if => :is_date, :allow_blank => true

  def numeric_question
    question.numeric?
  end

  def numeric_max_set
    question.max_set?
  end

  def numeric_min_set
    question.min_set?
  end

  def numeric_min
    if text_answer.present?
      errors.add(:text_answer, "is below minimum value of #{question.numeric_min} for the question '#{question.question_text}'") unless text_answer.to_f >= question.numeric_min.to_f
    end
  end

  def numeric_max
    if text_answer.present?
      errors.add(:text_answer, "is above maximum value of #{question.numeric_max} for the question '#{question.question_text}'") unless text_answer.to_f <= question.numeric_max.to_f
    end
  end

  # Because we always want to render onto the page a :text_answer,
  # but we use validates_date helper on :date_answer,
  # we need to move any errors so they will display to the user
  after_validation :move_date_answer_errors_to_text_answer_errors
  def move_date_answer_errors_to_text_answer_errors
    # uses a customization added by
    # config/initializers/active_record_error_move.rb
    errors.move("date_answer", "text_answer") if errors.on("date_answer")
  end


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
    question.is_required? || question.try(:question_element).try(:is_required?)
  end

  def is_date
    question.data_type == :date
  end

  def is_phone
    question.data_type == :phone
  end

  def before_validation
    if question.data_type == :phone and text_answer.present?
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

    concat_checkbox_codes if question.data_type == :check_box
  end

  def short_name
    question.short_name unless question.nil? || question.short_name.blank?
  end

  private

  def concat_checkbox_codes
    self.code = self.code.split(",").join("\n") if self.code
  end

end

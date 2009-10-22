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

# This class is all lies. Its looks a little like an AR class, but its
# not
class Questions
  include ActiveRecord::Validations
  include Enumerable

  class << self

    def from_form(form)
      new form
    end

    def human_attribute_name(attr)
      if attr =~ /\d+_(.*$)/
        $1.humanize.capitalize
      else
        attr.to_s.humanize
      end
    end

  end

  def initialize(form)
    @form = form
  end

  def size
    @form.questions.size
  end

  def each
    @form.questions.each do |q|
      yield errorfy(q) if block_given?
    end
  end

  def update(questions_hash)
    return true unless questions_hash
    errors.clear
    begin
      Question.transaction do
        questions_hash.each do |pkey, attr|
          question = @form.questions.find(pkey)
          next unless question
          question.short_name = attr[:short_name]
          record_question_errors(question) unless question.save
        end
        raise 'Errors saving short names' unless valid?
      end
    rescue
      ActiveRecord::Base.logger.error $!.message
      false
    else
      true
    end
  end

  def valid?
    validate
    errors.empty?
  end

  def validate
    Question.find_by_sql([<<-SQL, @form.id, @form.id]).each {|q| errors.add(field_name(q), "'#{q.short_name}' is already used in this form")}
      SELECT questions.id, questions.short_name FROM questions
        JOIN form_elements ON questions.form_element_id = form_elements.id
       WHERE EXISTS (SELECT 'x' FROM questions i
                       JOIN form_elements f ON i.form_element_id = f.id
                      WHERE form_id = ?
                        AND questions.short_name = i.short_name
                        AND questions.id > i.id)
         AND form_elements.form_id = ?
    SQL
  end

  private

  # copy errors from the group on individual questions so we can
  # hightlight fields w/ errors
  def errorfy(question)
    if question.errors.empty? && errors.on(field_name(question))
      errors.on(field_name(question)).each do |err|
        question.errors.add 'short_name', err
      end
    end
    question
  end

  # if individual question validations fail, we record those to
  # present to the user in an error message
  def record_question_errors(question)
    question.errors.each_full do |err|
      errors.add_to_base err
    end
  end

  def field_name(question)
    "#{question.id}_short_name"
  end
end

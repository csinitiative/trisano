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

# This class is all lies. Its looks a little like an AR class, but its
# not
class Questions
  include ActiveRecord::Validations
  include Enumerable

  class << self

    def from_form(form)
      new form
    end

    def self_and_descendants_from_active_record
      [self]
    end

    def human_name(options = {})
      default = self.name.humanize
      I18n.t(default, {:scope => [:activerecord, :models], :count => 1, :default => default}.merge(options))
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
        raise(I18n.translate('errors_saving_short_names')) unless valid?
      end
    rescue
      ActiveRecord::Base.logger.error $!
      if errors.empty?
        self.errors.add(:base, I18n.t(:unexpected_error, :scope => t_scope(:base)))
      end
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
    scope = t_scope(:short_name)
    Question.find_by_sql([<<-SQL, @form.id, @form.id]).each {|q| errors.add(field_name(q), I18n.t(:taken, :scope => scope, :short_name => q.short_name))}
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

  # since we're not really an AR
  def t_scope(*additional_scope)
    returning [] do |scope|
      scope << [:activerecord, :errors, :models, :questions, :attributes]
      scope << additional_scope
      scope.flatten!
    end
  end
end

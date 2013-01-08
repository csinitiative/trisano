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

joins = 'join questions q on answers.question_id = q.id join form_elements fe on q.form_element_id = fe.id join export_columns ec on fe.export_column_id = ec.id'
conditions = "fe.export_column_id is not null"
includes_option = { :question => { :question_element => :export_column }}

batch_count = 0
total_count = Answer.count(
  :joins => joins,
  :conditions => conditions,
  :include => includes_option
)

Answer.find_in_batches( :batch_size => 2000,
                        :joins => joins,
                        :conditions => conditions,
                        :include => includes_option,
                        :readonly => false) do |answers|
  batch_count += 1
  p "- Batch #{batch_count}, processing up to #{batch_count * 2000} of #{total_count} -"

  answers.each do |answer|
    answer_export_column = answer.question.question_element.export_column

    if (answer_export_column.data_type == 'radio_button')
      if (conversion_value = answer_export_column.export_conversion_values.detect { |ecv| ecv.value_from == answer.text_answer })
        answer.update_attribute(:export_conversion_value_id, conversion_value.id)
      end
    else
      first_answer_conversion_value = answer_export_column.export_conversion_values.first
      unless first_answer_conversion_value.nil?
        answer.update_attribute(:export_conversion_value_id, first_answer_conversion_value.id)
      end
    end
  end
end
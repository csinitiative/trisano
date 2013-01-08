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

def find_events_with_duplicate_answers
  ActiveRecord::Base.connection.execute(%Q{
    SELECT distinct(event_id)
    FROM answers
    GROUP BY event_id, question_id
    HAVING count(*) > 1
    ORDER BY event_id;
  })
end

def find_and_cleanup_duplicate_answers(event_id)
  answer_result = ActiveRecord::Base.connection.execute(%Q{
      SELECT a.event_id, a.id, a.question_id, a.text_answer, a.code, q.short_name, q.question_text
      FROM answers a
      LEFT JOIN questions q ON a.question_id = q.id
      WHERE event_id = #{event_id}
      AND question_id IN (
        SELECT question_id
        FROM answers
        WHERE event_id = #{event_id}
        GROUP BY question_id
        HAVING count(*) > 1
      )
      ORDER BY question_id, id;
    })
  cleanup_duplicate_answers(answer_result)
end

def cleanup_duplicate_answers(answer_result)
  questions_handled = []

  answer_result.each do |answer_record|
    unless questions_handled.include?(answer_record["question_id"])
      answers_for_question = answer_result.map { |answer|
        answer if answer["question_id"] == answer_record["question_id"]
      }.compact

      answer_ids_for_question = answers_for_question.map { |answer| answer["id"] }
      keeper_id = answer_to_keep(answers_for_question)
      answer_ids_to_delete = answer_ids_for_question.reject { |id| id == keeper_id }
      Answer.delete(answer_ids_to_delete)

      questions_handled << answer_record["question_id"]
    end
  end
end

def answer_to_keep(answers_for_question)
  answers_sans_blanks = answers_for_question.reject { |answer| answer["text_answer"].blank? }
  keeper = answers_sans_blanks.size == 1 ? answers_sans_blanks.first["id"] : answers_for_question.sort_by { |answer| answer["id"] }.pop["id"]
  log_csv_results(answers_for_question, keeper)
  keeper
end

def log_csv_results(answers_for_question, keeper)
  csv_output = []
  found_mismatch = false

  answers_for_question.each do |answer|
    found_mismatch = false
    csv_output << "#{answer["event_id"]}, #{answer["id"]}, #{sanitize_output_for_csv(answer["question_text"])}, #{answer["short_name"]}, #{sanitize_output_for_csv(answer["text_answer"])}, #{sanitize_output_for_csv(answer["code"])}, #{answer["id"] != keeper ? "true" : "" }, "
    found_mismatch = true if answers_for_question[0]["text_answer"] != answer["text_answer"]
  end

  csv_output.each do |line|
    line << "true" if found_mismatch
    $stdout.puts line
  end
end

def sanitize_output_for_csv(output)
  output.gsub(/[\r\n,]/, ' ') unless output.blank?
end

$stdout.puts "event_id, answer_id, question_text, short_name, text_answer, code, deleted, mismatch"

Answer.transaction do
  find_events_with_duplicate_answers.each do |event_record|
    find_and_cleanup_duplicate_answers(event_record["event_id"])
  end
end

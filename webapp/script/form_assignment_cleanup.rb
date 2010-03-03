# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

puts 'h1. Event form assignment migration'

i = 0
connection = ActiveRecord::Base.connection

puts "h2. Mark form assignment as having occurred for events with form references."


# A new flag was added to events in 1.2. This part of the script goes through existing events in
# batches. All events that already have form references are marked as having undergone form
# assignment. The event query below does an inner join on form references to limit the events
# returned to those with form references.
#
# This will prevent future duplicates.
Event.find_in_batches(:select => "distinct(events.id)", :batch_size => 500, :joins => "inner join form_references on events.id = form_references.event_id") do |event_group|
  i += 1
  puts "    * Processing #{i.ordinalize} group of 500 events"

  # For each event in each group, set the form as having undergone form assignment
  event_group.each do |event|
    connection.execute("UPDATE events SET undergone_form_assignment = true WHERE id = #{event.id};")
  end
end

i = 0

# Form duplicate cleanup. Again, events are limited to those with form references.
puts "h2. Cleaning up form assignment duplicates."

Event.find_in_batches(:select => "distinct(events.id)", :include => :form_references, :batch_size => 500, :joins => "inner join form_references on events.id = form_references.event_id") do |event_group|
  i += 1
  puts "\n"
  puts "h3. Processing #{i.ordinalize} group of 500 events"
  event_group.each do |event|

    if event.form_references.size > 1

      # For each event, we retrieve the form references, ordered by the template_id (the master form
      # from which the form was published. Duplicates could have different form_ids, but their template_id
      # will always be the same.
      sql = "SELECT fr.id, fr.event_id, fr.form_id, f.template_id "
      sql << "FROM form_references fr "
      sql << "INNER JOIN forms f on fr.form_id = f.id "
      sql << "WHERE event_id = #{event.id} "
      sql << "ORDER BY f.template_id, fr.form_id;"

      refs = connection.select_all(sql)

      # We need to keep track of the last template_id and last form_id we've seen. If we hit the
      # same template_id again, we've hit a duplicate. The form_id lets us know if we're looking
      # at the same version, or a different version of the same form.
      last_template_id = nil
      first_form_id = nil
      ref_count = 0

      refs.each do |ref|

        if ref_count == 0
          first_form_id = ref["form_id"]
        end

        if last_template_id == ref["template_id"]

          puts "* Duplicate form found on event #{event.id}"

          if(first_form_id != ref["form_id"])

            puts "** Duplicate is a different version. Deleting the form reference and answers."
            event.remove_forms(ref["form_id"].to_i)

          else

            puts "** Duplicate is a not a different version. Deleting the form reference."
            connection.execute("DELETE FROM form_references WHERE id = #{ref['id']}")

            puts "*** Looking for duplicate answers..."

            form = Form.find(ref["form_id"])

            form.form_element_cache.each do |element|
              if element.class.name == "QuestionElement"

                # We can't use the form element cache here, since that'll just give us the first answer it hits for a
                # question. Hit the database for all questions tied to an event and a question.
                answers = Answer.find(:all, :conditions => ["event_id = ? AND question_id = ?", event.id, form.form_element_cache.question(element).id])

                if answers.size > 1
                  if ((answers.size == 2) && (answers[0].text_answer == answers[1].text_answer))
                    puts "**** Duplicate answers are the same, just deleting one."
                    puts "{{{"
                    p answers
                    puts "}}}"
                    answers[0].destroy
                  else
                    puts "**** Duplicate answers are not the same, or there are more than two duplicate answers. Logging differences for a manual fix."
                    puts "{{{"
                    p answers
                    puts "}}}"
                  end
                end
              end
            end

          end
        end

        last_template_id = ref["template_id"]
        ref_count +=1
      end
    end
  end

end

# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

def assign_short_name(question, known_problem_questions)
  puts "#{question.question_text}"
  if known_problem_questions.has_key?(question.question_text)
    puts "  - We know about this question. Setting a short name"
    question.short_name = known_problem_questions[question.question_text]
    question.save!
  else
    puts "  ============== We don't know about this question =============="
  end
end

Question.transaction do

  puts 'Generating short names for questions on forms'
  
  known_problem_questions = {
    "AKA:" => "AKA",
    "ALT upper limit normal:" => "ALT_UPPER_NORMAL",
    "Date assigned:" => "DATE_ASSIGNED",
    "Date closed:" => "DATE_CLOSED",
    "Date collected:" => "DATE_COLLECTED",
    "Disease:" => "DISEASE",
    "Disposition:" => "DISPOSITION",
    "Disposition date:" => "DISPOSITION_DATE",
    "DIS worker number:" => "DIS_WORKER_NUMBER",
    "Does this contact have a co-morbidity?" => "CONTACT_CO_MORBIDITY",
    "For each treatment, list the dosage and duration:" => "TREATMENT_DOSAGE_DURATION",
    "How many sex partners has the case had in the past 3 months?" => "SEX_PARTNERS",
    "Initiation date:" => "INITIATION_DATE",
    "Interview date:" => "INTERVIEW_DATE",
    "Interview period:" => "INTERVIEW_PERIOD",
    "Is ALT level elevated?" => "ALT_ELEVATED",
    "Is the patient MSM (a man who has sex with men)?" => "PATIENT_MSM",
    "Is the patient still hospitalized?" => "PATIENT_HOSPITALIZED",
    "List species:" => "LIST_SPECIES",
    "Marital status:" => "MARITAL_STATUS",
    "New case number:" => "NEW_CASE_NUMBER",
    "Specify:" => "SPECIFY",
    "Types or brands:" => "TYPES_BRANDS",
    "Was patient in a wooded, brushy or grassy area (potential tick habitat) <30 days prior to onset of symptoms?" => "TICK_HABITAT",
    "Was the case interviewed?" => "CASE_INTERVIEWED"
  }

  questions_on_forms = Question.find(:all,
    :select => 'questions.*',
    :conditions => ["questions.short_name = '' AND form_elements.form_id IS NOT NULL"],
    :joins => "INNER JOIN form_elements ON questions.form_element_id = form_elements.id"
  )

  if questions_on_forms.size > 0
    questions_on_forms.each do |question|
      def question.short_name_filter
        # Do nothing. This turns off the change-prevention for published questions
      end

      assign_short_name(question, known_problem_questions)
    end
  else
    puts "  - No questions to update"
  end


  puts 'Generating short names for questions in the library'

  known_problem_questions = {
    "Did patient have contact with ANY animals (including farm animals, pets)?" => "ANIMAL_CONTACT",
    "Did the patient have contact with animal waste/manure?" => "ANIMAL_WASTE",
    "Did the patient have contact with an animal not listed above?" => "ANIMAL_NOT_LISTED",
    "Did the patient visit any of the following?" => "PATIENT_VISIT",
    "How often?" => "HOW_OFTEN",
    "Name(s) of store/restaurant/venue:" => "NAME_OF_PLACE",
    "Specify details:" => "SPECIFY_DETAILS",
    "Specify details (including dates):" => "SPECIFY_DETAILS_DATES",
    "Were any of the animals a new pet?" => "NEW_PET",
    "Were any of the animals sick (diarrhea)?" => "SICK_ANIMAL",
    "What animals did the patient have contact with?" => "WHAT_ANIMALS",
    "Where was it purchased?" => "WHERE_PURCHASED",
  }

  questions_in_library = Question.find(:all,
    :select => 'questions.*',
    :conditions => ["questions.short_name = '' AND form_elements.form_id IS NULL"],
    :joins => "INNER JOIN form_elements ON questions.form_element_id = form_elements.id"
  )

  if questions_in_library.size > 0
    questions_on_forms.each do |question|
      assign_short_name(question, known_problem_questions)
    end
  else
    puts "  - No questions to update"
  end

end

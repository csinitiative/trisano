# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

Question.transaction do

  puts 'Cleaning up existing short names'
  
  

  questions = Question.find_by_sql("select * from questions where short_name ILIKE '% %';")

  if questions.size > 0
    questions.each do |question|

      puts "Fixing up #{question.short_name}"

      def question.short_name_filter
        # Do nothing. This turns off the change-prevention for published questions
      end
      
      short_name = question.short_name.gsub(/_ /, "_").gsub(/ /, "_")
      puts "#{short_name}"
      question.short_name = short_name
      question.save!
    end
  else
    puts "  - No questions to update"
  end

end

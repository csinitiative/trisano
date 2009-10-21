When /^I change the "([^\"]*)" question\'s short name to "([^\"]*)"$/ do |question_text, short_name|
  question = @published_form.questions.select {|q| q.question_text == question_text}.first
  fill_in "questions[#{question.id}][short_name]", :with => short_name
end


When(/^I try to add a question to the default section without providing a short name$/) do
  add_question_to_view(@browser, "Default View", {
      :question_text => "Question without short name?",
      :data_type => "Single line text"
    }, true)
end

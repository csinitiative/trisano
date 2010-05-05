When /^I copy the question to the library root$/ do
  visit("/forms/to_library",
        :post,
        :reference_element_id => @question_element.id,
        :group_element_id => 'root')
end

Then /^the question should appear under no group in the library$/i do
  response.should have_selector('li') do |li|
    li.should contain(@question_element.question.question_text)
  end
end

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

Given /^I have a library group named "([^\"]*)"$/ do |name|
  @group_element = Factory.build(:group_element, :name => name)
  @group_element.save_and_add_to_form
end

When /^I copy the question to the library group "([^\"]*)"$/ do |group_name|
  @group_element = GroupElement.find_by_name(group_name)
  visit("/forms/to_library",
        :post,
        :reference_element_id => @question_element.id,
        :group_element_id => @group_element.id)
end

Then /^the question is in the library group$/ do
  @group_element.reload
  @group_element.children.any? do |c|
    c.question.try(:question_text) == @question_element.question.question_text
  end.should(be_true)
end

When /^I copy the question to an invalid library group$/ do
  @group_element = Factory.create(:group_element)
  visit("/forms/to_library",
        :post,
        :reference_element_id => @question_element.id,
        :group_element_id => @group_element.id)
end

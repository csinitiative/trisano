Given /^a person named "([^\"]*)" exists$/ do |name|
  first_name, last_name = name.split(' ')
  @person = Person.find_by_first_name_and_last_name(first_name, last_name)
  unless @person
    @person = Person.create_with_entity!(:last_name => last_name, :first_name => first_name)
  end
end

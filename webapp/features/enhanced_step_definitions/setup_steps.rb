Given /^I have real world data$/ do
  sql_data_file_path = File.join(RAILS_ROOT,"features","support","kdhe_prod_20120629.obfu.sql")
  raise "Real world data not found at #{sql_data_file_path}" unless File.exist?(sql_data_file_path)
  `psql postgres -c "DROP DATABASE trisano_test;"` 
  `psql postgres -c "CREATE DATABASE trisano_test;"`
  `psql trisano_test < #{sql_data_file_path}`
  `rake db:migrate`
end

Given /^I test the show event page of a large form$/ do
  visit "/cmrs/90242"
end

Given /^I am logged in as a real world user$/ do
  visit "/login"
  fill_in "User Name", :with => "brianb"
  fill_in "Password", :with => "Buchalter2!"
  click_button "Submit"
end

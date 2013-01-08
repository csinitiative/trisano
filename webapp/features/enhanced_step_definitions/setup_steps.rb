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

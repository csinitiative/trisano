# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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


Given /^I am not logged in$/ do

end

When /^My password expires$/ do
  User.current_user.update_attribute(:password_last_updated, 1.year.ago)
end

When /^I login with good credentials$/ do
  user = User.create(Factory.attributes_for(:user,
        :password => 'Helo1234!',
        :password_confirmation => 'Helo1234!'))
  puts user.inspect
  fill_in :user_session_user_name, :with => user.user_name
  fill_in :user_session_password, :with => 'Helo1234!'
  click_button "Submit"
end

When /^I login with expired password$/ do
  user = User.create(Factory.attributes_for(:user,
        :password => 'Helo1234!',
        :password_confirmation => 'Helo1234!',
        :password_last_updated => 1.year.ago))
  puts user.inspect
  fill_in :user_session_user_name, :with => user.user_name
  fill_in :user_session_password, :with => 'Helo1234!'
  click_button "Submit"
end

When /^I login with a bad password$/ do
  user = User.create(Factory.attributes_for(:user,
        :password => 'Helo1234!',
        :password_confirmation => 'Helo1234!'))
  puts user.inspect
  fill_in :user_session_user_name, :with => user.user_name
  fill_in :user_session_password, :with => 'stork'
  click_button "Submit"
end

When /^I login with a bad user name$/ do
  user = User.create(Factory.attributes_for(:user,
        :password => 'Helo1234!',
        :password_confirmation => 'Helo1234!'))
  puts user.inspect
  fill_in :user_session_user_name, :with => 'robertwrong'
  fill_in :user_session_password, :with => 'Helo1234!'
  click_button "Submit"
end
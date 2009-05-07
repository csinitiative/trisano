

# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

ARUP1_MSG = <<ARUP1
MSH|^~\&|ARUP|ARUP LABORATORIES^46D0523979^CLIA|UTDOH|UT|200903261645||ORU^R01|200903261645128667|P|2.3.1|1\r
PID|1||17744418^^^^MR||LIN^GENYAO^^^^^L||19840810|M||U^Unknown^HL70005|215 UNIVERSITY VLG^^SALT LAKE CITY^UT^84108^^M||^^PH^^^801^5854967|||||||||U^Unknown^HL70189\r
ORC||||||||||||^ROSENKOETTER^YUKI^K|||||||||University Hospital UT|50 North Medical Drive^^Salt Lake City^UT^84132^USA^B||^^^^^USA^B\r
OBR|1||09078102377|13954-3^Hepatitis Be Antigen^LN|||200903191011|||||||200903191011|X|^ROSENKOETTER^YUKI^K|||||||||F||||||9^Unknown\r
OBX|1|ST|13954-3^Hepatitis Be Antigen^LN|1|Positive||Negative||||F|||200903210007\r
ARUP1

messages = { :arup => ARUP1_MSG }

Given /^I have a lab message from "([^\"]*)"$/ do |msg_key|
  @lab_message = LabMessage.create(:hl7_message => messages[msg_key.downcase.to_sym])
end


When /^I visit the lab message new page$/ do
  visit new_lab_message_path
end

When /^I type the "([^\"]*)" message into "([^\"]*)"$/ do |msg, field|
  response.should have_xpath "//textarea[@id='#{field}']"
  fill_in field, :with => messages[msg.downcase.to_sym] || raise("no message #{msg}")
end

When /^I visit the lab message show page$/ do
  visit lab_message_path(@lab_message)
end

When /^I post an "([^\"]*)" message directly to "([^\"]*)"$/ do |msg, path|
  msg = messages[msg.downcase.to_sym] || msg
  http_accept("application/edi-hl7")
  visit path, :post, msg
end


Then /^I should see the sending facility$/ do
  response.should have_xpath("//label[text()='Sending Facility']")
  response.should contain(@lab_message.sending_facility)
end

Then /^I should see the patient\'s name$/ do
  response.should have_xpath("//label[text()='Patient']")
  response.should contain(@lab_message.patient_name)
end

Then /^I should see the lab name$/ do
  response.should have_xpath("//label[text()='Lab']")
  response.should contain(@lab_message.lab)
end

Then /^I should see the lab result$/ do
  response.should have_xpath("//label[text()='Result']")
  response.should contain(@lab_message.lab_result)
end

Then /^I should see the original message$/ do
  response.should contain(@lab_message.hl7_message.strip)
end

Then /^I should see the HL7 version$/ do
  response.should have_xpath("//label[text()='HL7 Version']")
  response.should contain(@lab_message.hl7_version)
end

Then /^I should receive a 200 response$/ do
  response.should be_success
end

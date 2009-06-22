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

require 'factory_girl'
require 'faker'

Factory.define :morbidity_event do |e|
  e.association :interested_party
  e.association :jurisdiction
  e.association :address
  e.association :disease_event
end  

Factory.define :contact_event do |e|
  e.association :interested_party
  e.association :jurisdiction
  e.association :address
  e.association :disease_event
  e.association :parent_event, :factory => :morbidity_event
end  

Factory.define :form do |f|
  f.short_name { Factory.next(:short_name) }
  f.name       { Factory.next(:long_name) }
  f.event_type 'contact_event'
end

Factory.define :form_reference do |fr|
  fr.association :form
end

Factory.define :section_element do |se|
  se.name { Factory.next(:long_name) }
end

Factory.define :view_element do |ve|
  ve.name { Factory.next(:long_name) }
end

Factory.define :person do |p|
  p.last_name { Factory.next(:last_name) }
end

Factory.define :place do |p|
  p.name { Factory.next(:place_name) }
end

Factory.define :person_entity do |pe|
  pe.association :person
  pe.email_addresses { |email_addresses| [email_addresses.association(:email_address)] }
end

Factory.define :email_address do |ea|
  ea.email_address { Factory.next(:email_address) }
end

Factory.define :place_entity do |pe|
  pe.association :place
end

Factory.define :interested_party do |ip|
  ip.association :person_entity
  ip.association :risk_factor, :factory => :participations_risk_factor
end

Factory.define :participations_risk_factor do |rf|
  rf.occupation { Factory.next(:occupation) }
end

Factory.define :jurisdiction do |j|
  j.association :place_entity
end

Factory.define :address do |a|
  a.street_number { Factory.next(:street_number) }
  a.street_name   { Factory.next(:street_name) }
end

Factory.define :disease_event do |de|
  de.association :disease
end

Factory.define :disease do |d|
  d.disease_name { Factory.next(:disease_name) }
  d.cdc_code     { Factory.next(:cdc_code) }
end

Factory.define :lab do |l|
  l.lab_results { |lr| [lr.association(:lab_result)] }
end

Factory.define :lab_result do |lr|
  lr.test_type { Factory.next(:test_type) }
  lr.lab_result_text 'positive'
end
  
Factory.define :answer_single_line_text, :class => :answer do |a|
  a.question    { |q| q.association(:question_single_line_text) }
  a.text_answer { Factory.next(:answer_text) }
end

Factory.define :question do |q|
  q.question_text { Factory.next(:question_text) }
  q.short_name    { Factory.next(:short_name) }
end

Factory.define :question_single_line_text, :parent => :question do |q|
  q.data_type 'single_line_text'
end

Factory.define :user do |u|
  u.uid { Factory.next(:uid) }
  u.user_name { Factory.next(:user_name) }
end

#
# Sequences
#

Factory.sequence :last_name do |n|
  "last_name_#{n}"
end

Factory.sequence :place_name do |n|
  "place_name_#{n}"
end

Factory.sequence :street_number do |n|
  "#{n}"
end

Factory.sequence :street_name do |n|
  "street name #{n}"
end

Factory.sequence :email_address do |n|
  "person#{n}@example.com"
end

Factory.sequence :disease_name do |n|
  "The dreaded lurgy #{n}"
end

Factory.sequence :cdc_code do |n|
  "#{50000 + n}"
end

Factory.sequence :test_type do |n|
  "lab test ##{n}"
end

Factory.sequence :occupation do |n|
  "Programmer #{n}"
end

Factory.sequence :question_text do |n|
  "#{n}. #{Faker::Lorem.sentence}?"
end

Factory.sequence :answer_text do |n|
  "#{n}. #{Faker::Lorem.sentence}"
end

Factory.sequence :short_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end

Factory.sequence :long_name do |n|
  "#{Faker::Lorem.words(3)} #{n}"
end

Factory.sequence :user_name do |n|
  "#{n}_#{Faker::Lorem.words(1)}"
end

Factory.sequence :uid do |n|
  "#{n}"
end

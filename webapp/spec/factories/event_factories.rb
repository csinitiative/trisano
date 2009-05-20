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

Factory.define :contact_event do |e|
  e.association :interested_party
  e.association :jurisdiction
  e.association :address
  e.association :disease_event
  e.labs {|l| [l.association(:lab)] } 
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
end

Factory.define :lab do |l|
  l.lab_results { |lr| [lr.association(:lab_result)] }
end

Factory.define :lab_result do |lr|
  lr.test_type { Factory.next(:test_type) }
  lr.lab_result_text 'positive'
end
  
  

# Sequences

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

Factory.sequence :test_type do |n|
  "lab test ##{n}"
end

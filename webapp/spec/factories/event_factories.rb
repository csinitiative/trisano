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
  e.jurisdiction { Factory.build(:jurisdiction) }
end

Factory.define :contact_event do |e|
  e.association :interested_party
  e.association :jurisdiction
  e.association :disease_event
  e.association :parent_event, :factory => :morbidity_event
end

Factory.define :encounter_event do |e|
  e.association :parent_event, :factory => :morbidity_event
end

Factory.define :place_event do |e|
  e.association :interested_place
  e.association :jurisdiction
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

Factory.define :clinician, :parent => :person do |c|
  c.person_type 'clinician'
end

Factory.define :place do |p|
  p.name { Factory.next(:place_name) }
end

Factory.define :person_entity do |pe|
  pe.person { Factory.build(:person) }
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
  ip.treatments {|treatments| [treatments.association(:participations_treatment)]}
end

Factory.define :interested_place do |ip|
  ip.association :place_entity
end

Factory.define :participations_risk_factor do |rf|
  rf.occupation { Factory.next(:occupation) }
end

Factory.define :participations_treatment do |pt|
  pt.treatment { Factory.next(:treatment_name) }
end

Factory.define :participations_contact do |pc|
  pc.contact_event { Factory.build(:contact_event) }
end

Factory.define :jurisdiction do |j|
  j.place_entity { create_jurisdiction_entity }
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

# common_test_type factory defined in common_test_type_factories.rb
Factory.define :lab_result do |lr|
  lr.test_type { |ctt| ctt.association(:common_test_type) }
end

Factory.define :answer do |a|
  a.question { |q| q.association(:question_single_line_text) }
  a.text_answer { Factory.next(:answer_text) }
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

Factory.define :task do |t|
  t.name { Factory.next(:task_name) }
  t.due_date Date.tomorrow
  t.association :user
end

Factory.define :event_with_task, :parent => :morbidity_event do |event|
  event.after_build do |event|
    Factory(:task, :event => event, :child_task => false)
  end
  event.after_create do |event|
    event.reload
  end
end

Factory.define :event_with_disease_event, :parent => :morbidity_event do |event|
  event.association :disease_event
end

Factory.define :note do |n|
  n.note "New note"
end

Factory.define :avr_group do |t|
  t.name { Factory.next(:avr_group_name) }
end

Factory.define :telephone do |t|
end

Factory.define :diagnostic_facility do |df|
end

Factory.define :hospitalization_facility do |hf|
end

Factory.define :attachment do |a|
end

Factory.define :event_queue do |eq|
  eq.queue_name   { Factory.next(:queue_name) }
  eq.jurisdiction { create_jurisdiction_entity }
end

Factory.define :code_name do |cn|
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

Factory.sequence :task_name do |n|
  "task_name_#{n}"
end

Factory.sequence :avr_group_name do |n|
  "avr_group_name_#{n}"
end

Factory.sequence :treatment_name do |n|
  "Potion Number #{n}"
end

Factory.sequence :queue_name do |n|
  "#{Faker::Lorem.words(1)} #{n}"
end

def create_diagnostic_facility!(name)
  create_place!(:diagnostic, name)
end

def create_reporting_agency!(name)
  create_place!(:agency, name)
end

def create_place_exposure!(name)
  place_event = Factory.build(:place_event)
  the_code = Place.epi_type_codes.first
  type = Code.find_or_create_by_code_name_and_the_code('placetype', the_code)
  place = place_event.interested_place.place_entity.place
  place.name = name
  place.place_types << type
  place_event.save!
end

def create_place!(type, name)
  place_entity = Factory.build(:place_entity)
  place_entity.place.name = name
  the_code = Place.send("#{type.to_s}_type_codes").first
  type = Code.find_or_create_by_code_name_and_the_code('placetype', the_code)
  place_entity.place.place_types << type
  place_entity.save!
end

def create_contact!(name)
  contact_event = Factory.build(:contact_event)
  person = contact_event.interested_party.person_entity.person
  person.last_name = name
  contact_event.save!
end

def searchable_event!(type, last_name)
  returning Factory.build(type) do |event|
    event.update_attributes!({
        :jurisdiction_attributes => {
          :secondary_entity_id => Place.unassigned_jurisdiction.try(:entity_id)},
        :interested_party_attributes => {
          :person_entity_attributes => {
            :person_attributes => {
              :last_name => last_name}}}})
  end
end

def searchable_person!(last_name)
  returning Factory.build(:person_entity) do |person|
    person.update_attributes!({
        :person_attributes => {
          :last_name => last_name}})
  end
end

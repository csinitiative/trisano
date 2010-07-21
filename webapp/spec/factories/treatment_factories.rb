require 'factory_girl'
require 'faker'

Factory.define(:treatment) do |t|
  t.treatment_name { Factory.next(:treatment_name) }
end


Factory.sequence :treatment_name do |n|
  "treatment_name_#{n}"
end
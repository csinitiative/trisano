require 'factory_girl'
require 'faker'

Factory.define(:treatment) do |t|
  t.treatment_name { Factory.next(:treatment_name) }
  t.treatment_type { Factory.create(:treatment_type) }
end


Factory.sequence :treatment_name do |n|
  "treatment_name_#{n}"
end
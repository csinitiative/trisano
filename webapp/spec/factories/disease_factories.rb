require 'factory_girl'

Factory.define :campylobacteriosis, :class => 'Disease' do |disease|
  disease.disease_name 'Campylobacteriosis'
end

Factory.define :shigellosis, :class => 'Disease' do |disease|
  disease.disease_name 'Shigellosis'
end

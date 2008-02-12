class Entity < ActiveRecord::Base
  # Ultimately, when dealing with maintaing change history, we'll want something like the following
  # has_many :people
  # has_one  :latest_person_edit, :class_name => 'Person', :order => 'created_at DESC'
  acts_as_reportable
  has_one :person
  validates_associated :person
end

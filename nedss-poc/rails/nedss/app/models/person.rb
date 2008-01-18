class Person < ActiveRecord::Base
  belongs_to :birth_gender, :class_name => 'Code'
  belongs_to :current_gender, :class_name => 'Code'
  belongs_to :ethnicity, :class_name => 'Code'
  belongs_to :race, :class_name => 'Code'
  belongs_to :primary_language, :class_name => 'Code'
 
# belongs_to :entity

  validates_presence_of :last_name
  validates_date :birth_date, :allow_nil => true
  validates_date :date_of_death, :allow_nil => true
end

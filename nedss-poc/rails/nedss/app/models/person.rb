require 'chronic'

class Person < ActiveRecord::Base
  belongs_to :birth_gender, :class_name => 'Code'
  belongs_to :current_gender, :class_name => 'Code'
  belongs_to :ethnicity, :class_name => 'Code'
  belongs_to :primary_language, :class_name => 'Code'
  belongs_to :food_handler, :class_name => 'Code'
  belongs_to :healthcare_worker, :class_name => 'Code'
  belongs_to :group_living, :class_name => 'Code'
  belongs_to :day_care_association, :class_name => 'Code'
  belongs_to :entity 

  validates_presence_of :last_name
  validates_date :birth_date, :allow_nil => true
  validates_date :date_of_death, :allow_nil => true
  
  before_save :generate_soundex_codes

  protected
  def validate
    if !date_of_death.blank? && !birth_date.blank?
      errors.add(:date_of_death, "The date of death precedes birth date") if Chronic.parse(date_of_death) < Chronic.parse(birth_date)
    end
  end
  
  def generate_soundex_codes
    if !first_name.blank?
      self.first_name_soundex = Text::Soundex.soundex(first_name)
    end
    
    self.last_name_soundex = Text::Soundex.soundex(last_name)
  end
  
end

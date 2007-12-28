require 'digest/sha1'

class Cmr < ActiveRecord::Base
  validates_presence_of :first_name
  before_create :generate_accession_number
  before_save :generate_age
  
  def generate_accession_number
    # Debt: Not machine safe. Only based on time. The requirement is still needed anyway
    self.accession_number = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
  end
  
  def generate_age
   # Is date_of_birth required? If yes, add validation and remove this check
   if (!self.date_of_birth.nil?)
    dob = self.date_of_birth
    date = Date.today
    day_diff = date.day - dob.day
    month_diff = date.month - dob.month - (day_diff < 0 ? 1 : 0)
    self.age = date.year - dob.year - (month_diff < 0 ? 1 : 0)
   end
  end
  
end

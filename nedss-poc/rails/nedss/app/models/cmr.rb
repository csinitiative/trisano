require 'digest/sha1'
require 'chronic'

class Cmr < ActiveRecord::Base
  belongs_to :disease
  belongs_to :patient
  before_create :generate_accession_number
  
  def generate_accession_number
    # Debt: Not machine safe. Only based on time. The requirement is still needed anyway
    self.accession_number = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
  end
  
  protected
  def validate
    #  An example of using Chronic for natural language date parsing
    # errors.add("date_of_birth", "has invalid format") unless Chronic.parse(self.date_of_birth)
  end
  
end

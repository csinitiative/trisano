class EntitiesLocation < ActiveRecord::Base
  belongs_to :location
  belongs_to :entity  

  belongs_to  :entity_location_type, :class_name => 'ExternalCode'
  belongs_to  :primary_yn, :class_name => 'ExternalCode'

  # TGF - This causes a tall stack trace on update. Haven't sorted it out yet.
  # validates_associated :location

  # Should validate that entity_location_type and primary_yn are legitimate codes

  # Debt: a terrible hack because location wasn't working in the
  # application the way same way it did in the console.
  def telephones
    Telephone.find(:all, :conditions => ['location_id = ?', location_id])
  end
  
 
  # Convenient read only attributes make presenting telephone
  # information easier. Maybe candidates for STI.
  def area_code
    current_phone.area_code if current_phone
  end

  def phone_number
    current_phone.phone_number if current_phone
  end

  def extension
    current_phone.extension if current_phone
  end

  def email_address
    current_phone.email_address if current_phone
  end

  def current_phone
    @current_phone ||= telephones.last if telephones.last
  end
end

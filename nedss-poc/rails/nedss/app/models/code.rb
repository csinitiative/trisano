class Code < ActiveRecord::Base

  def self.yes
   find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
  end

  def self.yes_id
   find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'").id
  end

  def self.other_place_type_id
   find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'").id
  end

  def self.unspecified_location_id
   find(:first, :conditions => "code_name = 'location' and the_code = 'U'").id
  end
end

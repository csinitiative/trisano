class Code < ActiveRecord::Base

  def self.yes
   find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
  end

  def self.yes_id
   code = find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
   code.id unless code.nil?
  end

  def self.other_place_type_id
   code = find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'")
   code.id unless code.nil?
  end

  def self.unspecified_location_id
   code = find(:first, :conditions => "code_name = 'location' and the_code = 'U'")
   code.id unless code.nil?
  end
end

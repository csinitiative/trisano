class Code < ActiveRecord::Base

  def self.yes
   find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
  end

  def self.other_place_type_id
   find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'").id
  end
end

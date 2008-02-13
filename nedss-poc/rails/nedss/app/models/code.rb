class Code < ActiveRecord::Base

  def self.yes
   find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
  end
end

class Code < ActiveRecord::Base

  def self.other_place_type_id
   code = find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'")
   code.id unless code.nil?
  end

end

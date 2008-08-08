class Code < ActiveRecord::Base

  def self.other_place_type_id
   code = find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'")
   code.id unless code.nil?
  end

  def self.interested_party
    Code.find_by_code_name_and_code_description('participant', 'Interested Party')
  end

end

class ExternalCode < ActiveRecord::Base
# acts_as_auditable

  def self.yes
    find(:first, :conditions => "code_name = 'yesno' and the_code = 'Y'")
  end

  def self.no
    find(:first, :conditions => "code_name = 'yesno' and the_code = 'N'")
  end

  def self.yes_id
    yes.id if yes
  end
  
  def self.no_id
    no.id if no
  end

  def self.unspecified_location_id
    code = find(:first, :conditions => "code_name = 'location' and the_code = 'UNK'")
    code.id unless code.nil?
  end

  def self.telephone_location_types
    find_all_by_code_name('telephonelocationtype', :order => 'sort_order')
  end
  
  def self.telephone_location_type_ids
    telephone_location_types.collect{|code| code.id}
  end

  def event_under_investigation?
    'eventstatus'.eql?(code_name) && ['UI', 'IC', 'RO-MGR'].include?(the_code)
  end

end

class ExternalCode < ActiveRecord::Base
  # If this is removed, adjust the query below in #find_codes_for_autocomplete
  # That query was a workaround for a defect in acts_as_auditable
  acts_as_auditable

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
  
  # Debt: This query bypasses AR because of an issue in acts_as_audible where
  # using an array in a condition was failing
  def self.find_codes_for_autocomplete(condition, limit=10)
    return [] if condition.nil?
    condition = sanitize_sql(["%s", condition.downcase])
    limit = sanitize_sql(["%s", limit])
    find_by_sql("select * FROM external_codes where LOWER(code_description) LIKE '#{condition}%' AND live is TRUE AND next_ver is NULL order by code_description limit #{limit};")
  end

  def event_under_investigation?
    'eventstatus'.eql?(code_name) && ['UI', 'IC', 'RO-MGR'].include?(the_code)
  end
  
end
class Telephone < ActiveRecord::Base
  belongs_to :location

  validates_format_of :phone_number, :with => /^\d{3}-?\d{4}$/, :message => 'must not be blank and must be 7 digits with an optional dash (e.g.5551212 or 555-1212)', :allow_blank => true
  validates_format_of :area_code, :with => /^\d{3}$/, :message => 'must be 3 digits', :allow_blank => true
  validates_format_of :extension, :with => /^\d{1,6}$/, :message => 'must have 1 to 6 digits', :allow_blank => true

  before_save :strip_dash_from_phone

  # A basic (###) ###-#### Ext. # format for phone numbers
  def simple_format
    number = ''
    number << "(#{self.area_code}) " unless self.area_code.blank?
    if phone_number.blank? || phone_number.include?('-')
      number << phone_number
    else
      number << phone_number.insert(3, '-')
    end
    number << " Ext. #{self.extension}" unless self.extension.blank?
    number.strip
  end


  protected
  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base("At least one telephone field must have a value")
    end
  end

  def strip_dash_from_phone
    phone_number.gsub!(/-/, '')
  end

end

class Address < ActiveRecord::Base
  belongs_to :location
  belongs_to :county, :class_name => 'ExternalCode'
  belongs_to :district, :class_name => 'ExternalCode'
  belongs_to :state, :class_name => 'ExternalCode'

  def number_and_street
    "#{self.street_number} #{street_name}".strip
  end

  def state_name   
    self.state.code_description if self.state
  end

  def district_name
    self.district.code_description if self.district
  end

  def county_name
    self.county.code_description if self.county
  end

  protected
  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base("At least one address field must have a value")
    end
  end
end

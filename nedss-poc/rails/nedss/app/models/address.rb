class Address < ActiveRecord::Base
  belongs_to :location
  belongs_to :county, :class_name => 'ExternalCode'
  belongs_to :district, :class_name => 'ExternalCode'
  belongs_to :state, :class_name => 'ExternalCode'

  protected
  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base("At least one address field must have a value")
    end
  end
end

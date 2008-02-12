class Address < ActiveRecord::Base
  acts_as_reportable
  belongs_to :location
  belongs_to :city, :class_name => 'Code'
  belongs_to :county, :class_name => 'Code'
  belongs_to :district, :class_name => 'Code'
  belongs_to :state, :class_name => 'Code'

  protected
  def validate
    if attributes.select {|k, v| !v.blank?}.empty?
      errors.add_to_base("At least one element must have a value")
    end
  end
end

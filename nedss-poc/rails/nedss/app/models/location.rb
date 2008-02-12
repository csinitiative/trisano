class Location < ActiveRecord::Base
  acts_as_reportable
  has_many :entities_locations
  has_many :entities, :through => :entities_locations
  
  has_many :addresses
  has_many :phones

  has_one :current_address, :class_name => 'Address', :order => 'created_at DESC'

  # Populated by PersonEntity to label as work, home, etc.
  attr_accessor :type
  attr_writer :primary

  def primary?
    @primary
  end

  validates_associated :addresses
end

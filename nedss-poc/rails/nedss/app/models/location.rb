class Location < ActiveRecord::Base
  has_many :entities_locations
  has_many :entities, :through => :entities_locations
  
  has_many :addresses
  has_many :phones

  has_one :current_address, :class_name => 'Address', :order => 'created_at DESC'

  # Populated by PersonEntity to label as work, home, etc.
  attr_accessor :type
  attr_writer :primary

  # Need more validation against bad input, assumes a happy path

  before_validation :save_associations
  after_validation :clear_base_error
  after_update :update_entities_locations

  def primary?
    @primary
  end

  def entities_location
    @entities_location
  end

  def entities_location=(attributes)
    if new_record? or attributes[:entity_id].blank?  # If create/new or edit
      entities_locations.build(attributes)
      @entities_location = entities_locations.last
    else                                             # update
      entity_location = entities_locations.detect { |e| e.entity_id == attributes[:entity_id].to_i }
      entity_location.attributes = attributes
      @entities_location = entity_location
    end
  end  

  def address
    @address || addresses.last
  end

  def address=(attributes)
    @address = Address.new(attributes)
  end  

  private

  def save_associations
    addresses << address unless @address.nil?
  end

  def update_entities_locations
    entities_location.save
  end

  def clear_base_error
    errors.delete(:entities_locations)
    errors.delete(:addresses)
  end
end

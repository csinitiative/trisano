class Location < ActiveRecord::Base
  has_many :entities_locations, :dependent => :destroy
  has_many :entities, :through => :entities_locations
  
  has_many :addresses
  has_many :telephones, :dependent => :destroy, :order => 'created_at DESC'

  has_one :current_address, :class_name => 'Address', :order => 'created_at DESC'
  has_one :current_phone, :class_name => 'Telephone', :order => 'created_at DESC'

  # Populated by PersonEntity to label as work, home, etc.
  attr_accessor :type
  attr_writer :primary

  validates_associated :telephones
  validates_associated :addresses

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

  def telephone
    @telephone || telephones.last
  end

  def telephone=(attributes)
    @telephone = Telephone.new(attributes)
  end  

  protected

  def validate
    if Utilities::model_empty?(address) and Utilities::model_empty?(telephone)
      errors.add_to_base("You must enter at least a partial address or partial phone number.")
    end
  end

  def save_associations
    if new_record?
      addresses << address unless Utilities::model_empty?(address)
      telephones << telephone unless Utilities::model_empty?(telephone)
    else
      addresses << address unless Utilities::model_empty?(address) and Utilities::model_empty?(telephone)
      telephones << telephone unless Utilities::model_empty?(telephone) and Utilities::model_empty?(address)
    end
  end

  def update_entities_locations
    entities_location.save if entities_location
  end

  def clear_base_error
    errors.delete(:entities_locations)
    errors.delete(:addresses)
    errors.delete(:telephones)
  end
end

class Entity < ActiveRecord::Base
  has_many :people, :before_add => :set_entity_type

  #TODO: TGF DELETE THESE WHEN DONE WITH REFACTORING
  has_many :places, :order => 'created_at ASC', :before_add => :set_entity_type
  has_one  :current_place, :class_name => 'Place', :order => 'created_at DESC'

  #TODO: TGF CHANGE PLACE_TEMP TO PLACE WHEN REFACTORING COMPLETE
  has_one :place_temp, :class_name => "Place"
  has_one :person_temp, :class_name => "Person"

  has_many :entities_locations, :foreign_key => 'entity_id', :order => 'entity_location_type_id, created_at DESC'
  has_many :locations, :through => :entities_locations

  # TODO: SERIOUS DEBT, Nothing enforces just one primary location
  has_one :primary_entities_location, 
    :class_name => 'EntitiesLocation', 
    :foreign_key => 'entity_id', 
    :conditions => [ "primary_yn_id = ?", ExternalCode.yes_id ],
    :order => 'created_at DESC'
  
  # Just grabbing the most recent phone here. Not supporting multiples yet.
  has_one :primary_phone_entities_location, 
    :class_name => 'EntitiesLocation', 
    :foreign_key => 'entity_id', 
    :conditions => [ "location_type_id = ?", Code.find_by_code_name_and_code_description('locationtype', "Telephone Location Type").id],
    :order => 'created_at DESC'
  
  has_and_belongs_to_many :races, 
    :class_name => 'ExternalCode', 
    :join_table => 'people_races', 
    :association_foreign_key => 'race_id', 
    :order => 'code_description'

  attr_protected :entity_type
  validates_presence_of :entity_type
  validates_associated :people
  validates_associated :place_temp
  validates_associated :person_temp
  validates_associated :entities_locations

  before_validation :save_entity_associations
  after_save :save_location_info

  def person
    @person || Person.find_by_entity_id(self.id) || person_temp
  end

  def person=(attributes)
    if new_record?
      @person = Person.new(attributes)
    else
      person.update_attributes(attributes)
    end
    set_entity_type(person)
  end  

  # Debt: Remove this when the associations are correct on user.rb.
  # The role view uses this accessor to get a place name in a
  # collection_select.
  #
  #TODO: TGF REMOVE THESE TWO METHODS WHEN REFACTROING COMPLETE
  def place
    @place || current_place
  end

  def place=(attributes)
    @place = Place.new(attributes)
    set_entity_type(@place)
  end

  def entities_location
    @entities_location || primary_entities_location
  end

  def entities_location=(attributes)
    @entities_location = EntitiesLocation.new(attributes)
  end
  
  #TGR: support for multiple phones.
  def telephone_entities_locations
    telephone_location_type_ids = ExternalCode.telephone_location_type_ids
    entities_locations.select {|el| telephone_location_type_ids.include? el.entity_location_type_id}
  end

  def telephone_entities_location
    @telephone_entities_location || primary_phone_entities_location
  end

  def telephone_entities_location=(attributes)
    @telephone_entities_location = EntitiesLocation.new(attributes)
  end
  
  def address
    @address || (primary_entities_location.nil? ? nil : primary_entities_location.location.address)
  end

  def address=(attributes)
    @address = Address.new(attributes)
  end  

  def telephone
    @telephone || (primary_phone_entities_location.nil? ? nil : primary_phone_entities_location.location.telephone)
  end

  def telephone=(attributes)
    @telephone = Telephone.new(attributes)
  end  

  # Debt: Not sure I like this.
  def current_locations
    entities_locations.map do |el|
      location = locations.find(el.location_id)
      location.type = el.entity_location_type.code_description
      location.primary = el.primary_yn.the_code == "Y" ? true : false
      location
    end
  end

  def case_id
    return nil if new_record?
    primary_entity = Participation.find_by_primary_entity_id(id)
    case_id = primary_entity.event_id unless primary_entity.nil?
    case_id.nil? ? nil : case_id
  end

  private

  def validate
    # Uncomment when person is factored in
    # Extend when animal and material support is added
    # errors.add_to_base("Entity must be associated to a person or place") if place.nil and person.nil

    errors.add(:address) unless @address.valid? unless Utilities::model_empty?(@address)
    errors.add(:telephone) unless @telephone.valid? unless Utilities::model_empty?(@telephone)
  end

  #TODO: TGF: REMOVE WHEN REFACTORING COMPLETE
  def set_entity_type(record)
    self.entity_type = record.class.name.downcase
  end

  #TODO: TGF: REMOVE WHEN REFACTORING COMPLETE
  def save_entity_associations
    case entity_type
    when "person"
      people << @person unless @person.nil?
     
    #TODO: TGF: REMOVE WHEN REFACTORING COMPLETE
    when "place"
      places << @place unless @place.nil?

      # More 'when' clauses as needed
    end
  end

  def save_location_info
    unless Utilities::model_empty?(@address)
       entities_location.entity_id = id
      a_attrs = @address.nil?   ? {} : @address.attributes
      address_location = Location.new(:entities_location => entities_location.attributes, :address => a_attrs)
      address_location.save
    end
    
    unless Utilities::model_empty?(@telephone)
       telephone_entities_location.entity_id = id
       t_attrs = @telephone.nil? ? {} : @telephone.attributes
       telephone_location = Location.new(:entities_location => telephone_entities_location.attributes, :telephone => t_attrs)    
       telephone_location.save
    end
    
  end

end

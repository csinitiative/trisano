class Entity < ActiveRecord::Base
  has_many :people, :before_add => :set_entity_type
  has_one  :current_person, :class_name => 'Person', :order => 'created_at DESC'

  has_many :places, :before_add => :set_entity_type
  has_one  :current_place, :class_name => 'Place', :order => 'created_at DESC'

  has_many :animals, :before_add => :set_entity_type
  #  has_one  :current_animal, :class_name => 'Animal', :order => 'created_at DESC'

  has_many :materials, :before_add => :set_entity_type
  #  has_one  :current_material, :class_name => 'Material', :order => 'created_at DESC'

  has_many :entities_locations, :foreign_key => 'entity_id', :select => 'DISTINCT ON (entity_location_type_id) *', :order => 'entity_location_type_id, created_at DESC'
  has_many :locations, :through => :entities_locations

  # TODO: SERIOUS DEBT, Nothing enforces just one primary location
  has_one :primary_entities_location, 
          :class_name => 'EntitiesLocation', 
          :foreign_key => 'entity_id', 
          :conditions => [ "primary_yn_id = ?", Code.yes_id ],
          :order => 'created_at DESC'

  has_and_belongs_to_many :races, 
    :class_name => 'Code', 
    :join_table => 'people_races', 
    :association_foreign_key => 'race_id', 
    :order => 'code_description'

  attr_protected :entity_type
  validates_presence_of :entity_type

  before_validation :save_entity_associations
  after_validation :clear_base_error
  after_save :save_location_info

  def person
    @person || current_person
  end

  def person=(attributes)
    @person = Person.new(attributes)
    set_entity_type(@person)
  end  

   # Debt: Remove this when the associations are correct on user.rb.
   # The role view uses this accessor to get a place name in a
   # collection_select.
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

  def address
    @address || (primary_entities_location.nil? ? nil : primary_entities_location.location.address)
  end

  def address=(attributes)
    @address = Address.new(attributes)
  end  

  def telephone
    @telephone || (primary_entities_location.nil? ? nil : primary_entities_location.location.telephone)
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

  private

  def validate
    errors.add(:address) unless @address.valid? unless Utilities::model_empty?(@address)
    errors.add(:telephone) unless @telephone.valid? unless Utilities::model_empty?(@telephone)
  end

  def set_entity_type(record)
    self.entity_type = record.class.name.downcase
  end

  def save_entity_associations
    case entity_type
    when "person"
      people << @person unless @person.nil?
    when "place"
      places << @place unless @place.nil?

      # More 'when' clauses as needed
    end
  end

  def save_location_info
    if not (Utilities::model_empty?(@address) and Utilities::model_empty?(@telephone))
      entities_location.entity_id = id
      a_attrs = @address.nil?   ? {} : @address.attributes
      t_attrs = @telephone.nil? ? {} : @telephone.attributes
      l= Location.new(:entities_location => entities_location.attributes, :address => a_attrs, :telephone => t_attrs)
      l.save
    end
  end

  def clear_base_error
    errors.delete(:people)
    errors.delete(:telephone)
    errors.delete(:address)
  end
end

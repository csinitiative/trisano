class Entity < ActiveRecord::Base
  has_many :people, :before_add => :set_entity_type
  has_one  :current_person, :class_name => 'Person', :order => 'created_at DESC'

  has_many :places, :before_add => :set_entity_type
  has_one  :current_place, :order => 'created_at DESC'

  has_many :animals, :before_add => :set_entity_type
  has_one  :current_animal, :order => 'created_at DESC'

  has_many :materials, :before_add => :set_entity_type
  has_one  :current_material, :order => 'created_at DESC'

  has_many :entities_locations, :foreign_key => 'entity_id'
  has_many :locations, :through => :entities_locations

  has_and_belongs_to_many :races, 
                          :class_name => 'Code', 
                          :join_table => 'people_races', 
                          :association_foreign_key => 'race_id', 
                          :order => 'code_description'

  attr_protected :entity_type
  validates_presence_of :entity_type

  before_validation :save_entity_associations
  after_validation :clear_base_error

  validates_associated :entities_locations

  def person
    @person || current_person
  end

  def person=(attributes)
    @person = Person.new(attributes)
    set_entity_type(@person)
  end  

  def entities_location
    @entities_location
  end

  def entities_location=(attributes)
    @entities_location = EntitiesLocation.new(attributes)
  end  

  def address
    @address
  end

  def address=(attributes)
    @address = Address.new(attributes)
  end  

  def telephone
    @telephone
  end

  def telephone=(attributes)
    @telephone = Telephone.new(attributes)
  end  

  # [PGL] Not sure I like this.
  def current_locations
    locations.map do |l|
      entity_location = entities_locations.find_by_location_id(l.id)
      l.type = entity_location.entity_location_type.code_description
      l.primary = entity_location.primary_yn.the_code == "Y" ? true : false
      l
    end
  end

  private

#  def validate
#    address.valid? unless Utilities::model_empty?(address)
#    telephone.valid? unless Utilities::model_empty?(telephone)
#  end

  def set_entity_type(record)
    self.entity_type = record.class.name.downcase
  end

  def save_entity_associations
    case entity_type
    when "person"
      people << @person unless @person.nil?

    # More 'when' clauses as needed
    end

    if not (Utilities::model_empty?(address) and Utilities::model_empty?(telephone))
      l = Location.new
      l.addresses << address unless Utilities::model_empty?(address)
      l.telephones << telephone unless Utilities::model_empty?(telephone)
      entities_location.location = l
      entities_locations << entities_location
    end
  end

  def clear_base_error
    errors.delete(:people)
    errors.delete(:entities_locations)
    entities_location.errors.delete(:location) unless entities_location.nil?
  end
end

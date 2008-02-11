class PersonEntity < ActiveRecord::Base
  set_table_name "entities"
  acts_as_reportable
  has_many :people, :foreign_key => 'entity_id'
  has_one  :current, :class_name => 'Person', :foreign_key => 'entity_id', :order => 'created_at DESC'

  has_many :entities_locations, :foreign_key => 'entity_id'
  has_many :locations, :through => :entities_locations

  validates_associated :people
  validates_associated :current

  def self.find_all
    # There's a bug in rails that causes the :select clause to be ignored if there's a :include.
    # See here: http://dev.rubyonrails.org/ticket/7147#comment:12.  It prevents me from doing 
    # something like this
    #
    # find(:all, 
    #      :include => :people, 
    #      :select => 'DISTINCT ON (people.entity_id), people.last_name, people.first_name', 
    #      :conditions => 'entities.id = people.entity_id',
    #      :order => 'people.last_name, people.first_name, people.created_at DESC')
    #
    # There's a monkey patch available, but for now, reverting to plain SQL.

    find_by_sql("SELECT DISTINCT ON (people.entity_id) entities.id " +
                "FROM entities, people " +
                "WHERE entities.id = people.entity_id " +
                "ORDER BY people.entity_id, people.created_at, people.last_name, people.first_name DESC;")
  end

  def current_locations
    locations.map do |l|
      entity_location = entities_locations.find_by_location_id(l.id)
      l.type = entity_location.entity_location_type.code_description
      l.primary = entity_location.primary_yn.code_description == "Yes" ? true : false
      l
    end
  end

  def current_location_by_id(id)
    current_locations.select {|l| l.id == id.to_i }.first
  end
end

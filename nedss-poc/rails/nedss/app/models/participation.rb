class Participation < ActiveRecord::Base
  belongs_to :lab_event
  belongs_to :primary_entity, :foreign_key => :primary_entity_id, :class_name => 'Entity'
  belongs_to :secondary_entity, :foreign_key => :secondary_entity_id, :class_name => 'Entity'

  has_many :hospitals_participations

  before_validation :save_associations
  validates_associated :primary_entity

  def entity_primary
    @entity_primary || primary_entity
  end

  def entity_primary=(attributes)
    @entity_primary = Entity.new(attributes)
  end

  def hospitals_participation
    @hospitals_participation ||= hospitals_participations.last
  end

  def hospitals_participation=(attributes)
    hospitals_participations.build(attributes)
  end  

  protected

  def save_associations
    self.primary_entity = entity_primary
  end
end

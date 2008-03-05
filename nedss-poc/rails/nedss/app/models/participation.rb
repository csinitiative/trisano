class Participation < ActiveRecord::Base
  belongs_to :event
  belongs_to :primary_entity, :foreign_key => :primary_entity_id, :class_name => 'Entity'
  belongs_to :secondary_entity, :foreign_key => :secondary_entity_id, :class_name => 'Entity'

  has_many :hospitals_participations

  before_validation :save_associations
  validates_associated :primary_entity

  def active_primary_entity
    @active_primary_entity || primary_entity
  end

  def active_primary_entity=(attributes)
    @active_primary_entity = Entity.new(attributes)
  end

  def hospitals_participation
    @hospitals_participation ||= hospitals_participations.last
  end

  def hospitals_participation=(attributes)
    hospitals_participations.build(attributes)
  end  

  private

  def save_associations
    self.primary_entity = active_primary_entity
  end
end

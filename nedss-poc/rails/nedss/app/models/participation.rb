class Participation < ActiveRecord::Base
  belongs_to :event
  belongs_to :primary_entity, :foreign_key => :primary_entity_id, :class_name => 'Entity'
  belongs_to :secondary_entity, :foreign_key => :secondary_entity_id, :class_name => 'Entity'

  has_many :hospitals_participations, :order => 'created_at ASC'
  has_many :participations_treatments, :order => 'created_at ASC'
  has_many :participations_risk_factors, :order => 'created_at ASC'

  validates_associated :primary_entity
  validates_associated :secondary_entity

  before_validation :save_associations

  def active_primary_entity
    @active_primary_entity || primary_entity
  end

  def active_primary_entity=(attributes)
    if new_record?
      @active_primary_entity = Entity.new(attributes)
    else
      active_primary_entity.update_attributes(attributes)
    end
  end

  def active_secondary_entity
    @active_secondary_entity || secondary_entity
  end

  def active_secondary_entity=(attributes)
    if new_record?
      @active_secondary_entity = Entity.new(attributes)
    else
      active_secondary_entity.update_attributes(attributes)
    end
  end

  def hospitals_participation
    @hospitals_participation ||= hospitals_participations.last
  end

  def hospitals_participation=(attributes)
    hospitals_participations.build(attributes)
  end 
  
  def participations_treatment
    @participations_treatment ||= ParticipationsTreatment.new
  end

  def participations_treatment=(attributes)
    participations_treatments.build(attributes) unless attributes.values_blank?
  end  

  def participations_risk_factor
    @participations_risk_factor ||= participations_risk_factors.last
  end

  def participations_risk_factor=(attributes)
    participations_risk_factors.build(attributes)
  end  

  private

  def save_associations
    self.primary_entity = active_primary_entity unless Utilities::model_empty?(active_primary_entity)
    self.secondary_entity = active_secondary_entity unless Utilities::model_empty?(active_secondary_entity)
  end
end

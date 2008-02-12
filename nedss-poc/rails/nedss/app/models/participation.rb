class Participation < ActiveRecord::Base
  acts_as_reportable
  belongs_to :lab_event
  belongs_to :person_entity, :foreign_key => :primary_entity_id
end

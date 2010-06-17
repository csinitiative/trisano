class CoreFieldsDisease < ActiveRecord::Base
  belongs_to :disease
  belongs_to :core_field

  validates_presence_of :disease
  validates_presence_of :core_field
end

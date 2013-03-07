class DiseasesForm < ActiveRecord::Base
  belongs_to :form
  belongs_to :disease
  attr_accessible :auto_assign, :disease_id, :form_id
end
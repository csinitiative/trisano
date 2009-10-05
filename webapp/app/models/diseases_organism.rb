class DiseasesOrganism < ActiveRecord::Base
  belongs_to :disease
  belongs_to :organism
end

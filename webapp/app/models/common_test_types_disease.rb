class CommonTestTypesDisease < ActiveRecord::Base
  belongs_to :disease
  belongs_to :common_test_type

  validates_uniqueness_of :disease_id, :scope => :common_test_type_id
end

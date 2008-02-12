class Telephone < ActiveRecord::Base
  acts_as_reportable
  belongs_to :location
end

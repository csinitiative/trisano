class Disease < ActiveRecord::Base
  has_many :cmrs
  validates_presence_of :name
end

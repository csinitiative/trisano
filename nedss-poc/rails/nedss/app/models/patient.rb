class Patient < ActiveRecord::Base
  has_many :cmrs
end

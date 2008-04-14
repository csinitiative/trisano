class Disease < ActiveRecord::Base
  belongs_to :program
  
  validates_presence_of :name
  
end

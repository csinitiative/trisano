class Group < ActiveRecord::Base
  belongs_to :section
  has_many :questions, :order => :position
  
  acts_as_list :scope => :section
  
end

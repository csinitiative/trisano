class Section < ActiveRecord::Base
  belongs_to :form
  has_many :groups, :order => :position
  
  acts_as_list :scope => :form
  
  validates_presence_of :name
end

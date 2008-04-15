class Section < ActiveRecord::Base
  belongs_to :form
  has_many :groups_sections
  has_many :groups, :through => :groups_sections
  
  acts_as_list :scope => :form
  
  validates_presence_of :name
end

class Section < ActiveRecord::Base
  belongs_to :form
  
  acts_as_list :scope => :form
  
   validates_presence_of :name
end

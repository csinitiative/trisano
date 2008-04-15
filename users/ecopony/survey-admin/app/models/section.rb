class Section < ActiveRecord::Base
  belongs_to :form
  
   validates_presence_of :name
end

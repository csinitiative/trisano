class Section < ActiveRecord::Base
  belongs_to :form
  
  acts_as_list :scope => "form_id"
  
   validates_presence_of :name
end

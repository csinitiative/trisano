class FormElement < ActiveRecord::Base
  acts_as_nested_set
  belongs_to :form  
end

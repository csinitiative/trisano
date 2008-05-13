class FormElement < ActiveRecord::Base
  acts_as_nested_set :scope => :form_id
  belongs_to :form  
end

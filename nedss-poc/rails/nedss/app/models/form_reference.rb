class FormReference < ActiveRecord::Base
  belongs_to :event
  belongs_to :form
end

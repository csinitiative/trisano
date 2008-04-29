class Form < ActiveRecord::Base
  belongs_to :disease
  belongs_to :jurisdiction, :class_name => "Entity", :foreign_key => "jurisdiction_id"
end

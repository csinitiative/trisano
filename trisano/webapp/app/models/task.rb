class Task < ActiveRecord::Base

  belongs_to :user
  belongs_to :event

  validates_presence_of :user_id, :name
  validates_length_of :name, :maximum => 255, :allow_blank => true
  validates_length_of :description, :maximum => 255, :allow_blank => true

end

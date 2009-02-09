class Task < ActiveRecord::Base

  belongs_to :user
  belongs_to :event

  validates_presence_of :user_id, :name
  validates_length_of :name, :maximum => 255, :allow_blank => true

  after_create :create_note

  def create_note
    if !self.notes.blank? && !self.event.nil?
      self.event.add_note(self.notes, "clinical")      
    end
  end

end

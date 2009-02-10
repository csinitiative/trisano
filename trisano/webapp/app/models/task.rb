class Task < ActiveRecord::Base

  belongs_to :user
  belongs_to :event
  belongs_to :category, :class_name => 'ExternalCode', :foreign_key => :category_id

  validates_presence_of :user_id, :name
  validates_length_of :name, :maximum => 255, :allow_blank => true

  after_create :create_note

  def category_name
    self.category.code_description unless self.category.nil?
  end
  
  def create_note
    if !self.notes.blank? && !self.event.nil?
      self.event.add_note(self.notes, "clinical")      
    end
  end

end

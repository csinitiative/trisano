# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class Task < ActiveRecord::Base

  VALID_STATUSES = %w( pending complete not_applicable )
  
  belongs_to :user
  belongs_to :event
  belongs_to :category, :class_name => 'ExternalCode', :foreign_key => :category_id

  validates_presence_of :user_id, :name
  validates_length_of :name, :maximum => 255, :allow_blank => true
  validates_inclusion_of :status, :in => VALID_STATUSES, :message => "is not valid"
  validates_date :due_date

  before_validation :set_status
  before_save :create_note

  attr_protected :user_id

  def category_name
    self.category.code_description unless self.category.nil?
  end

  # simplifies sorting
  def user_name
    self.user.best_name unless self.user.blank?
  end

  def validate
    validate_task_assignment
  end

  private

  def create_note
    return if self.event.nil?
    if new_record?
      unless self.notes.blank?
        self.event.add_note("Task created.\n\nName: #{self.name}\nNotes: #{self.notes}", "clinical")
      end
    else
      existing_task = Task.find(self.id)
      unless existing_task.status == self.status
        self.event.add_note("Task status change.\n\n'#{self.name}' changed from #{existing_task.status.humanize unless existing_task.status.nil?} to #{self.status.humanize unless self.status.nil?}", "clinical")
      end
    end
  end
  
  def set_status
    self.status = "pending" if new_record?
  end

  def validate_task_assignment
    unless self.user_id.blank?
      task_assignee_ids = User.task_assignees_for_jurisdictions(User.current_user.jurisdictions_for_privilege(:assign_task_to_user)).collect { |user| user.id }
      self.errors.add_to_base("Insufficient privileges for task assignment") unless ( (task_assignee_ids.include?(self.user_id)) || (self.user_id == User.current_user.id) )
    end
  end
  
end

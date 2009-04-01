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
  
  belongs_to :user
  belongs_to :event
  belongs_to :category, :class_name => 'ExternalCode', :foreign_key => :category_id
  has_many   :repeating_tasks, :class_name => 'Task',  :foreign_key => :repeating_task_id
  
  class << self
    def status_array
      [["Pending", "pending"], ["Complete", "complete"], ["Not applicable", "not_applicable"]]
    end

    def valid_statuses
      @valid_statuses ||= status_array.map { |status| status.last }
    end

    def interval_array
      [["Daily", "day"], ["Weekly", "week"], ["Monthly", "month"], ["Yearly", "year"]]
    end

    def valid_intervals
      @valid_intervals ||= interval_array.map { |interval| interval.last }
    end
  end
  
  validates_presence_of :user_id, :name
  validates_length_of :name, :maximum => 255, :allow_blank => true
  validates_inclusion_of :status, :in => self.valid_statuses, :message => "is not valid"
  validates_date :due_date
  validates_date :until_date, :allow_nil => true
  
  before_validation :set_status
  before_save :create_note
  after_create :create_repeating_tasks

  attr_protected :user_id, :repeating_task_id
  attr_accessor :child_task

  def category_name
    self.category.code_description unless self.category.nil?
  end

  # simplifies sorting
  def user_name
    self.user.best_name unless self.user.blank?
  end

  def validate
    unless (self.due_date.blank?)
      self.errors.add(:due_date, "must fall within the next two years") unless(self.due_date <= 2.years.from_now.to_date)
    end

    validate_task_assignment
    validate_repeating_task_attributes
  end
  
  def disease_name
    self.safe_call_chain(:event, :disease_event, :disease, :disease_name)
  end

  private

  def should_repeat?
    (!self.repeating_interval.blank? && !self.until_date.blank?)
  end

  def clone_for_repeating
    task = self.clone
    task.until_date = nil
    task.repeating_interval = nil
    task.child_task = true
    task
  end

  def create_note
    return if self.event.nil?
    if new_record?
      if !child_task && !self.notes.blank?
        note = "Task created.\n\nName: #{self.name}\nDescription: #{self.notes}"
        note << "\n\nRepeats every #{self.repeating_interval.to_s.downcase} until #{self.until_date.to_s}" if should_repeat?
        self.event.add_note(note, "clinical")
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

  def create_repeating_tasks
    if should_repeat?
      begin
        self.repeating_task_id = self.id
        self.save
        date = self.due_date + 1.send(self.repeating_interval)

        while (date <= self.until_date.to_date)
          task = clone_for_repeating
          task.due_date = date
          task.save
          date += 1.send(self.repeating_interval)
        end
      rescue Exception => ex
        logger.error ex
        self.errors.add_to_base("Unable to create repeating tasks.")
        return false
      end
    end
  end

  def validate_task_assignment
    unless self.user_id.blank?
      task_assignee_ids = User.default_task_assignees.collect(&:id)      
      self.errors.add_to_base("Insufficient privileges for task assignment.") unless ( (task_assignee_ids.include?(self.user_id)) || (self.user_id == User.current_user.id) )
    end
  end

  def validate_repeating_task_attributes
    self.errors.add_to_base("A repeating task requires an interval and an until date.") if ( (!self.repeating_interval.blank? && self.until_date.blank?) ||  (self.repeating_interval.blank? && !self.until_date.blank?) )

    if should_repeat?
      self.errors.add(:repeating_interval, "The task interval is invalid") unless(Task.valid_intervals.include?(self.repeating_interval.to_s))
      self.errors.add(:until_date, "date must fall within the next two years") unless(self.until_date.to_time <= 2.years.from_now)
      unless self.due_date.blank?
        self.errors.add(:until_date, "date must come after the original due date") unless(self.until_date.to_time > self.due_date)
      end
    end
  end
  
end

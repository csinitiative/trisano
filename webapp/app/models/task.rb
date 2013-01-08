
# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
    def priority_array
      [
        [I18n.t('low')   , "low"   ],
        [I18n.t('medium'), "medium"],
        [I18n.t('high')  , "high"  ]
      ]
    end

    def valid_priorities
      @valid_priorities ||= priority_array.map { |priority| priority.last }
    end

    def status_array
      [
        [I18n.t('task_statuses.pending'), "pending"],
        [I18n.t('task_statuses.complete'), "complete"],
        [I18n.t('task_statuses.not_applicable'), "not_applicable"]
      ]
    end

    def valid_statuses
      @valid_statuses ||= status_array.map { |status| status.last }
    end

    def interval_array
      [
        [I18n.t('task_intervals.day'), "day"],
        [I18n.t('task_intervals.week'), "week"],
        [I18n.t('task_intervals.month'), "month"],
        [I18n.t('task_intervals.year'), "year"]
      ]
    end

    def valid_intervals
      @valid_intervals ||= interval_array.map { |interval| interval.last }
    end
  end

  validates_presence_of :user_id, :name
  validates_length_of :name, :maximum => 255, :allow_blank => true
  validates_inclusion_of :status, :in => self.valid_statuses, :message => :is_not_valid
  validates_inclusion_of :priority, :in => self.valid_priorities, :message => :is_not_valid
  validates_date  :due_date,
                  :on_or_before => lambda { 2.years.from_now.to_date },
                  :on_or_before_message => :due_date_range
  validates_date :until_date, :allow_blank => true

  before_validation :set_status
  before_validation :set_priority
  before_save :create_note
  after_create :create_repeating_tasks

  attr_protected :user_id, :repeating_task_id
  attr_accessor :child_task
  attr_accessor :system_generated

  def category_name
    self.category.code_description unless self.category.nil?
  end

  def user_name
    self.user.best_name unless self.user.blank?
  end

  def validate
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
        note = I18n.translate("system_notes.task_created", :name => self.name, :notes => self.notes, :locale => I18n.default_locale)

        if should_repeat?
          note << "\n\n"
          note << I18n.translate("system_notes.task_repeats",
            :repeating_interval => self.repeating_interval.to_s.downcase,
            :until_date => self.until_date.to_s,
            :locale => I18n.default_locale
          )
        end

        self.event.add_note(note, "clinical")
      end
    else
      existing_task = Task.find(self.id)
      unless existing_task.status == self.status
        self.event.add_note(I18n.translate("system_notes.task_status_change",
            :name => self.name,
            :existing_status => existing_task.status.humanize,
            :new_status => self.status.humanize,
            :locale => I18n.default_locale
          ), "clinical")
      end
    end
  end

  def set_status
    self.status = "pending" if new_record?
  end

  def set_priority
    self.priority = "medium" if self.priority.blank?
  end

  def create_repeating_tasks
    if should_repeat?
      begin
        self.repeating_task_id = self.id
        self.save
        next_due_time = self.due_date + 1.send(self.repeating_interval)
        next_due_date = next_due_time.to_date

        while (next_due_date <= self.until_date.to_date)
          task = clone_for_repeating
          task.due_date = next_due_date
          task.save
          next_due_time += 1.send(self.repeating_interval)
          next_due_date = next_due_time.to_date
        end
      rescue Exception => ex
        logger.error ex
        self.errors.add_to_base(:repeating_task_failure)
        return false
      end
    end
  end

  def validate_task_assignment
    return if self.user_id.blank? or system_generated
    task_assignee_ids = User.default_task_assignees.collect(&:id)
    self.errors.add_to_base(:insufficient_privileges) unless ( (task_assignee_ids.include?(self.user_id)) || (self.user_id == User.current_user.id) )
  end

  def validate_repeating_task_attributes
    self.errors.add_to_base(:repeating_task_invalid) if ( (!self.repeating_interval.blank? && self.until_date.blank?) ||  (self.repeating_interval.blank? && !self.until_date.blank?) )

    if should_repeat?
      self.errors.add(:repeating_interval, :invalid) unless(Task.valid_intervals.include?(self.repeating_interval.to_s))
      self.errors.add(:until_date, :out_of_range) unless(self.until_date.to_time <= 2.years.from_now)
      unless self.due_date.blank?
        self.errors.add(:until_date, I18n.translate('task_repeat_date_must_be_after_due_date')) unless(self.until_date.to_time > self.due_date)
      end
    end
  end

end

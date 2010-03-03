# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

class ProductionDuplicateAnswerCleanup < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      say "Removing a single answer known to be a duplicate."

      begin
        answer = Answer.find(263600)
        say "Answer was found. Attempting to delete."
        answer.destroy
      rescue
        say "Answer could not be found"
      end
    end

  end

  def self.down
  end
end

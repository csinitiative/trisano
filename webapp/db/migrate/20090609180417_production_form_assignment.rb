# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition.

class ProductionFormAssignment < ActiveRecord::Migration
  def self.up
    if RAILS_ENV == 'production'
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/form_assignment_cleanup.rb"
    end
  end

  def self.down
  end
end

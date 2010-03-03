# Copyright (C) 2009, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

class TrisanoLocalesGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template "db/migrate/add_translation_tables.rb", "db/migrate"
    end
  end
end

def file_name
  'add_translation_tables'
end

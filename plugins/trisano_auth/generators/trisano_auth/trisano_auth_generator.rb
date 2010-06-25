# Copyright (C) 2009, 2010, Collaborative Software Initiative
#
# This file is part of CSI TriSano Enterprise Edition..

class TrisanoAuthGenerator < Rails::Generator::Base
  def manifest
    record do |m|

      m.migration_template "db/migrate/add_trisano_auth_support_to_users.rb", "db/migrate"

    end
  end
end

def file_name
  "add_trisano_auth_support_to_users"
end

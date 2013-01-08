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


# capture the query for testing purposes
# COMMENTED OUT CAUSE RAILS EDGE AS OF 02/24/09 DOESN'T LIKE IT
if ActiveRecord::Base.respond_to? :_find_by_sql_with_capture
  p "Find by sql with capture defined"
end
module ActiveRecord
  class Base
    class << self 
      def _find_by_sql_with_capture(query)
        @last_query = query
        find_by_sql_without_capture(query)
      end
      
      # Rails 2.3 thinks find_by_sql is a dynamic finder (e.g: find_by_last_name) and that blows things up
      # alias_method_chain :find_by_sql, :capture
      alias_method :find_by_sql_without_capture, :find_by_sql
      alias_method :find_by_sql, :_find_by_sql_with_capture
      
      def last_query
        @last_query
      end

      def reset_last_query
        @last_query = nil
      end
    end
  end
end

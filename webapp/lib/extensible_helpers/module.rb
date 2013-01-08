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
class Module

  # register a module to extend an existing helper.
  # works around rails plugin load ordering
  def extend_helper(target, &block)
    target.to_s.camelize.constantize.helper_extensions << self.to_s
    if block_given?
      instance_eval do
        @included = block
        def self.included(base)
          base.class_eval(&@included)
        end
      end
    end
  end

  # makes a helper module extensible by plugins
  def extensible_helper
    def helper_extensions
      unless defined?(@@helper_extensions)
        @@helper_extensions = Hash.new {|hash, key| hash[key] = Set.new}
      end
      @@helper_extensions[self.to_s.underscore.to_sym]
    end

    def self.included(base)
      helper_extensions.each do |ext|
        unless base.included_modules.include? ext.constantize
          base.class_eval { include ext.constantize }
        end
      end
    end
  end

end

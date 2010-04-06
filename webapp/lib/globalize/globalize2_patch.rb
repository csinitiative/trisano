# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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
#
# Patch to the globalize2 plugin to get around an issue in JRuby:
#
# http://jira.codehaus.org/browse/JRUBY-3530
#

module Globalize
  module Backend
    class Static < Pluralizing
      alias :original_translate :translate
      def translate(locale, key, options = {})
        result = original_translate(locale, key, options)
        result.is_a?(Translation::Static) ? result.to_s : result
      end
    end
  end
end
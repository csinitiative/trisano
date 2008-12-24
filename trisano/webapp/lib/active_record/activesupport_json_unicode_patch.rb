# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

# Monkey patch to enable Rails JSON decoding to properly handle unicode escape
# sequences. Just passes through to the JSON gem.
#
# See: 
# http://www.digitalhobbit.com/archives/2008/08/27/rails-and-json-containing-unicode-characters/

require 'json'

module ActiveSupport
  module JSON
    def self.decode(json)
      ::JSON.parse(json)
    end
  end
end

# The above JSON require trips up existing to_json calls that go through the ActiveSupport stuff (which
# also patches Enumerable). This is just a kluge to make the method call explicit for form exporting,
# so it doesn't go through the json gem code.
#
# The Rails JSON code, while lacking in unicode escape sequence support, is nice in that it includes
# the methods options, so questions can be included in the form elements dump.
#
# Debt: There very well may be a cleaner way to do this, but it was release day and this worked.
module Enumerable
  def patched_array_to_json(options = {})
    "[#{map { |value| ActiveSupport::JSON.encode(value, options) } * ', '}]"
  end
end

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

class CodeSelectCache

  def initialize
    @codes_cache = EventCodesCache.new
  end

  def drop_down_selections(code_name, event=nil)
    unless @codes_cache.loaded?(event)
      populate_cache(event)
    end
    @codes_cache[event][code_name]
  end

  private

  def populate_cache(event)
    load_external_codes(event)
    load_codes
  end

  def load_external_codes(event)
    ExternalCode.selections_for_event(event).each do |code|
      @codes_cache[event][code.code_name] << code
    end
  end

  def load_codes
    Code.active.exclude_jurisdiction.each do |code|
      @codes_cache[nil][code.code_name] << code
    end
  end

  class EventCodesCache
    def initialize
      @nil_event_cache = code_name_hash
      @event_cache = Hash.new { |hash, event| hash[event] = code_name_hash }
    end

    def [](key)
      if key
        @event_cache[key]
      else
        @nil_event_cache
      end
    end

    def loaded?(event)
      not self[event].empty?
    end

    private

    def code_name_hash
      Hash.new { |hash, code_name| hash[code_name] = [] }
    end
  end
end

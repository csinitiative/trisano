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
class TouchEventFilter
  def self.filter(controller)
    touch controller.instance_variable_get("@event") unless controller.request.xhr?
  end

  def self.touch(object, attribute = nil)
    current_time = Time.current

    if attribute
      object.write_attribute(attribute, current_time)
    else
      object.write_attribute('updated_at', current_time) if object.respond_to?(:updated_at)
      object.write_attribute('updated_on', current_time) if object.respond_to?(:updated_on)
    end
  
    object.save!
  end
end

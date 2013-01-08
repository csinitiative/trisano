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
class Utilities
  class << self
    def parse_phone(phone_no)
      digits = phone_no.gsub(/\D/, '')
      area_code = number = extension = nil
      case digits.length
      when 7
        number = digits
      when 10
        area_code = digits.slice!(0,3)
        number = digits
      when 11..15
        area_code = digits.slice!(0,3)
        number = digits.slice!(0,7)
        extension = digits
      else
        raise ArgumentError, "Number must contain 7, 10, or 11-15 digits"
      end
      return area_code, number, extension
    end

  end
end

module CallChainable

  def safe_call_chain(*messages)
    receiver = self
    messages.each do |msg|
      return nil if receiver.nil?
      receiver = receiver.send(msg)
    end
    receiver
  end

end

ActiveRecord::Base.send(:include, CallChainable)

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
# Monkeypatch to allow you to delete errors
# # There is currently no way to do that, making it tough when you have custom
# # validation trickery and Rails includes errors you don't want (such as a generic
# # base error on the association name)
#
# # Usage:
# # @customer.errors.delete(:email)
ActiveRecord::Errors.class_eval do
  def delete(attribute)
    @errors.delete(attribute.to_s)
  end
end

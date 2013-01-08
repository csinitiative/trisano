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
module I18nCoreField

  def name
    name = I18n.t(name_key, :scope => i18n_scope)
    if name.is_a?(Hash)
      name = I18n.t(:name, :scope => i18n_scope << name_key)
    end
    name
  end

  def name_key
    core_path_segments.last
  end

  def i18n_scope
    core_path_segments.unshift('event_fields').slice(0...-1)
  end

  def core_path_segments
    core_path.gsub(/\[\d+\]/, '').gsub(']','').split('[')
  end
end

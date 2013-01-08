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
# Creates a form that only edits new records.
class ImmutableFormBuilder < ExtendedFormBuilder

  def initialize(object_name, object, template, options, proc)
    super
    unless @object.nil? || @object.new_record?
      extend(ImmutableMethods)
    end
  end

  module ImmutableMethods
    def text_field(method, options={})
      @template.send(:h, @object.send(method))
    end

    def render_type_selector(types, options={})
      result = label(:place_types, @template.t(:place_type))
      result << @object.formatted_place_descriptions
      result
    end

    def dropdown_code_field(attribute, code_name, options={}, html_options={}, event=nil)
      core_follow_up(attribute, html_options, event) do |attribute, html_options|
        code_field = attribute.to_s.gsub(/_id$/, '')
        @object.send(code_field).try(:code_description) || ""
      end
    end
  end
end

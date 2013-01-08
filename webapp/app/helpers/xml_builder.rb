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
class XmlBuilder

  def initialize(*args, &block)
    @options = args.extract_options!
    @template = args.pop
    @object = args.pop
    @current_object = @object
    @name = args.pop || @object.class.name.underscore
    @proc = block
  end

  def link_to(url, options={})
    options = options.symbolize_keys
    options[:rel] = link_relation_for(options[:rel])
    @template.tag('atom:link', options.merge(:href => url))
  end

  def render(attribute, options = {})
    options[:rel] = link_relation_for(options[:rel]) if options[:rel]
    value = @current_object.send(attribute)
    case value
    when Array
      values = value.map { |v| cast(v) }
      values << options
      tags attribute, *values
    else
      tags attribute, cast(value), options
    end
  end

  def build
    if @object.is_a? Array
      tags @name, @options do
        index_tags(@object)
      end
    else
      tags @name, @template.capture(self, &@proc), @options
    end
  end

  def xml_for(attribute, options={}, &block)
    tag_name = nested_attribute(attribute) || attribute
    new_instance_or_array = association_instance(attribute)
    options = options.dup
    XmlBuilder.new(tag_name, new_instance_or_array, @template, options, &block).build
  end

  def fields
    @current_object.xml_fields
  end

  private

  def link_relation_for(rel)
    return rel.to_s if rel.to_s.starts_with? 'http'
    understood = %w(self alternate bookmark edit related previous next first last up enclosure index route)
    understood.include?(rel.to_s) ? rel.to_s : "https://wiki.csinitiative.com/display/tri/Relationship+-+#{rel.to_s.camelize}"
  end

  def cast(value)
    case value
      when Date
        value.xmlschema
      when Time
        value.xmlschema
      else
        @template.send(:h, value)
    end
  end

  def tags(name, *values_and_options)
    tag_name = name.to_s.dasherize
    options = values_and_options.extract_options!
    if block_given?
      open_tag(tag_name, yield, options)
    else
      if values_and_options.empty?
        closed_tag(tag_name, options)
      else
        values_and_options.collect do |value|
          open_tag(tag_name, (value || ""), options)
        end.join("\n")
      end
    end
  end

  def open_tag(tag_name, value, options)
    result = @template.tag(tag_name, options, true)
    result << value
    result << "</#{tag_name}>"
  end

  def closed_tag(tag_name, options)
    @template.tag(tag_name, options)
  end

  def nested_attribute(attribute)
    "#{attribute}_attributes" if @current_object.respond_to? "#{attribute}_attributes="
  end

  def association_instance(attribute)
    reflection = @current_object.class.reflections[attribute]
    if reflection.macro == :has_many
      @current_object.send(attribute) + [reflection.klass.new]
    else
      @current_object.send(attribute) || reflection.klass.new
    end
  end

  def index_tags(objects)
    i = -1
    objects.map do |object|
      @current_object = object
      tags "i#{i += 1}", @template.capture(self, &@proc), @options.dup
    end.join("\n")
  end
end

class XmlBuilder

  def initialize(*args, &block)
    @options = args.extract_options!
    @template = args.pop
    @object = args.pop
    @name = args.empty? ? @object.class.name.underscore : args.pop
    @proc = block
  end

  def link_to(url, options={})
    options = options.symbolize_keys
    options[:rel] = link_relation_for(options[:rel])
    @template.tag('atom:link', options.merge(:href => url))
  end

  def render(attribute, options = {})
    options[:rel] = link_relation_for(options[:rel]) if options[:rel]
    value = @object.send(attribute)
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
    tags @name, @template.capture(self, &@proc), @options
  end

  def xml_for(attribute, options ={}, &block)
    tag_name = nested_attribute(attribute) || attribute
    XmlBuilder.new(tag_name, association_instance(attribute), @template, options, &block).build
  end

  def fields
    @object.xml_fields
  end

  private

  def link_relation_for(rel)
    return rel.to_s if rel.to_s.starts_with? 'http'
    understood = %w(self alternate bookmark edit related previous next first last up enclosure index)
    understood.include?(rel.to_s) ? rel.to_s : "https://wiki.csinitiative.com/display/tri/Relationship+-+#{rel.to_s.camelize}"
  end

  def cast(value)
    case value
    when Date
      value.xmlschema
    else
      @template.send(:h, value)
    end
  end

  def tags(name, *values_and_options)
    tag_name = name.to_s.dasherize
    options = values_and_options.extract_options!
    if values_and_options.empty?
      @template.tag tag_name, options
    else
      values_and_options.collect do |value|
        result = @template.tag(tag_name, options, true)
        result << (value || "")
        result << "</#{tag_name}>"
      end.join("\n")
    end
  end

  def nested_attribute(attribute)
    "#{attribute}_attributes" if @object.respond_to? "#{attribute}_attributes="
  end

  def association_instance(attribute)
    @object.send(attribute) || @object.class.reflections[attribute].klass.new
  end
end

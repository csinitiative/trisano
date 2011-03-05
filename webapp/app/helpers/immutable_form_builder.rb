# Creates a form that only edits new records.
class ImmutableFormBuilder < ExtendedFormBuilder

  def initialize(object_name, object, template, options, proc)
    unless object.new_record?
      extend(ImmutableMethods)
    end
    super
  end

  module ImmutableMethods
    def text_field(method, options={})
      @template.send(:h, @object.send(method))
    end

    def render_type_selector(types)
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

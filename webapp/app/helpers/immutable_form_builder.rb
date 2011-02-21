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
      @template.h(@object.send(method))
    end
  end
end

# Rails 2.3.5 does not support multiple error messages on an attribute.
# This patch fixes that. It should be removed once we're off 2.3.5

module ActiveRecord::AutosaveAssociation
  private
  def association_valid?(reflection, association)
    return true if association.destroyed? || association.marked_for_destruction?

    unless valid = association.valid?
      if reflection.options[:autosave]
        association.errors.each_error do |attribute, error|
          attribute = "#{reflection.name}.#{attribute}"
          errors.add(attribute, error.dup) unless duplicate_error_message?(error)
        end
      else
        errors.add(reflection.name)
      end
    end
    valid
  end

  def duplicate_error_message?(new_error)
    errors.detect { |attr,message| message == new_error.message }
  end
end

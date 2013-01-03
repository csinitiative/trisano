module ActiveRecord
  class Errors
    def move(old_attribute, new_attribute)
      @errors[new_attribute] = @errors.delete(old_attribute)
    end
  end
end

#
# Adding some additional with_scope methods.
#
ActiveRecord::Base.instance_eval do
  protected

  def with_scope_unless(condition, with_scope_options, &block)
    unless condition
      with_scope with_scope_options do
        block.call
      end
    else
      block.call
    end
  end

  def with_scope_if(condition, with_scope_options, &block)
    if condition
      with_scope with_scope_options do
        block.call
      end
    else
      block.call
    end
  end

end

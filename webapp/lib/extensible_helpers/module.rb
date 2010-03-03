class Module

  # register a module to extend an existing helper.
  # works around rails plugin load ordering
  def extend_helper(target, &block)
    target.to_s.camelize.constantize.helper_extensions << self.to_s
    if block_given?
      instance_eval do
        @included = block
        def self.included(base)
          base.class_eval(&@included)
        end
      end
    end
  end

  # makes a helper module extensible by plugins
  def extensible_helper
    def helper_extensions
      unless defined?(@@helper_extensions)
        @@helper_extensions = Hash.new {|hash, key| hash[key] = Set.new}
      end
      @@helper_extensions[self.to_s.underscore.to_sym]
    end

    def self.included(base)
      helper_extensions.each do |ext|
        unless base.included_modules.include? ext.constantize
          base.class_eval { include ext.constantize }
        end
      end
    end
  end

end

# ActsAsAuditable

module ActsAsAuditable
    def self.included(mod)
        mod.extend(ClassMethods)
    end

    module ClassMethods
        def acts_as_auditable
            extend ActsAsAuditable::SingletonMethods
            include ActsAsAuditable::InstanceMethods
        end
    end

    module SingletonMethods
	def find_every(options)
	    options[:order] = 'created_at DESC'
	    super
	end
    end

    module InstanceMethods
	def update_attributes(attributes)
            self.attributes = attributes
	    save
	end
    end

end

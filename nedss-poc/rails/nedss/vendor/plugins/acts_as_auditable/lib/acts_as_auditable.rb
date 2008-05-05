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
       def method_missing(method_id, *arguments)
          if match = /^find_(all_by|by)_([_a-zA-Z]\w*)$/.match(method_id.to_s)
            finder = determine_finder(match)

            attribute_names = extract_attribute_names_from_match(match)
            super unless all_attributes_exists?(attribute_names)

            self.class_eval %{
              def self.#{method_id}(*args)
                options = args.last.is_a?(Hash) ? args.pop : {}
                attributes = construct_attributes_from_arguments([:#{attribute_names.join(',:')}], args)
                finder_options = { :conditions => attributes, :order => 'created_at DESC' }
                validate_find_options(options)
                set_readonly_option!(options)

                if options[:conditions]
                  with_scope(:find => finder_options) do
                    ActiveSupport::Deprecation.silence { send(:#{finder}, options) }
                  end
                else
                  ActiveSupport::Deprecation.silence { send(:#{finder}, options.merge(finder_options)) }
                end
              end
            }, __FILE__, __LINE__
            send(method_id, *arguments)
          elsif match = /^find_or_(initialize|create)_by_([_a-zA-Z]\w*)$/.match(method_id.to_s)
            instantiator = determine_instantiator(match)
            attribute_names = extract_attribute_names_from_match(match)
            super unless all_attributes_exists?(attribute_names)

            self.class_eval %{
              def self.#{method_id}(*args)
                if args[0].is_a?(Hash)
                  attributes = args[0].with_indifferent_access
                  find_attributes = attributes.slice(*[:#{attribute_names.join(',:')}])
                else
                  find_attributes = attributes = construct_attributes_from_arguments([:#{attribute_names.join(',:')}], args)
                end

                options = { :conditions => find_attributes, :order => 'created_at DESC' }
                set_readonly_option!(options)

                record = find_initial(options)
                if record.nil?
                  record = self.new { |r| r.send(:attributes=, attributes, false) }
                  #{'record.save' if instantiator == :create}
                  record
                else
                  record
                end
              end
            }, __FILE__, __LINE__
            send(method_id, *arguments)
          else
            super
          end
        end
    end

    module InstanceMethods
	def update_attributes(attributes)
            self.attributes = attributes
	    save
	end
    end

end

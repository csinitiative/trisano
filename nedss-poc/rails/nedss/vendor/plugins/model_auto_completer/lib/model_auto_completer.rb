module ModelAutoCompleter #:nodoc:
  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end

  module ClassMethods
    # Class method to automate 
    def auto_complete_belongs_to_for(object, association, method, options={}) #:nodoc:
      define_method("auto_complete_belongs_to_for_#{object}_#{association}_#{method}") do
        find_options = { 
          :conditions => ["LOWER(#{method}) LIKE ?", '%' + params[association][method].downcase + '%'], 
          :order => "#{method} ASC",
          :limit => 10
        }.merge!(options)
      
        klass = object.to_s.camelize.constantize.reflect_on_association(association).options[:class_name].constantize
        @items = klass.find(:all, find_options)

        render :inline => "<%= model_auto_complete_result @items, '#{method}' %>"
      end
    end
  end
end

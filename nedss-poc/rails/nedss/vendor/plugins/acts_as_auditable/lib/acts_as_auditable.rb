# ActsAsAuditable

module ActsAsAuditable
    class ActiveRecord
        def update_attributes(attributes)
            self.attributes = attributes
	    save
	end
    end
end

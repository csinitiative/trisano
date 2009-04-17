# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

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
	    # live implies that the record hasn't been deleted, and next_ver points to
	    # the ID of the next version.  If it is null, this implies that it is the 
	    # most recent
	    if options[:conditions].nil?
	        options[:conditions] = "live is TRUE and next_ver is NULL"
	    else
	        # Conditions can be an array, a string, or a hash...
	        if options[:conditions].is_a?(String)
	            options[:conditions] << " AND live is TRUE AND next_ver is NULL"
		else
		    if options[:conitions].is_a?(Array)
		        options[:conditions] << "live is TRUE"
		        options[:conditions] << "next_ver is NULL"
		    else
                        options[:conditions].merge!({"live" => TRUE, "next_ver" => nil})
		    end
		end
	    end
	    super
	end
    end

    module InstanceMethods
        def destroy
            update_attribute("live",FALSE)
	    save!
	    freeze
	end
	def update_attributes(attributes)
	    @old_attr = @attributes.clone
	    @old_attr.merge!(attributes)
	    @old_attr.delete('id')
	    @old_attr.delete('created_at')
	    @old_attr.delete('updated_at')
	    @old_attr['previous_ver'] = id
	    @new = self.class.new(@old_attr)
	    @new.save!
	    self.update_attribute("next_ver",@new.id)
	    self.save!
	end
    end

end

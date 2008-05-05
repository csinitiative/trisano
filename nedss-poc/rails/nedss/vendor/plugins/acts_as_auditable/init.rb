require 'acts_as_auditable'

ActiveRecord::Base.send(:include, ActsAsAuditable)

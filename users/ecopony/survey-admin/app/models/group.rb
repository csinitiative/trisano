class Group < ActiveRecord::Base
  has_many :groups_sections
  has_many :sections, :through => :groups_sections
end

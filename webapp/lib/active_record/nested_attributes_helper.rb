# Some common rejection methods for nested attributes
require 'trisano/nested_attributes_helper'

ActiveRecord::Base.class_eval do
  private
  include Trisano::NestedAttributesHelper
end

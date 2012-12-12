# Some common rejection methods for nested attributes
require 'trisano/nested_attributes_helper'

class ActiveRecord::Base
  private

  class << self
    include Trisano::NestedAttributesHelper
  end
end

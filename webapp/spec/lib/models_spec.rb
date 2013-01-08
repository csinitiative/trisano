# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

require File.dirname(__FILE__) + '/../spec_helper'

describe Models do

  describe "translated class names" do

    it "should exist for all classes extending ActiveRecord::Base" do
      I18n.locale = :test

      Dir.new("#{RAILS_ROOT}/app/models").entries.each do |file_name|
        unless File.directory?(file_name) || file_name.match(/^\./)

          instance = nil

          begin
            instance = File.basename(file_name,".rb").camelcase.new
          rescue
            # Couldn't instantiate the object. We assume for now we don't care about objects we can't instantiate.
          end

          if !instance.nil? && instance.is_a?(ActiveRecord::Base)
            instance.class.human_name[0...1].should == "x"
          end
        end
      end

      I18n.locale = :en
    end
  end
end

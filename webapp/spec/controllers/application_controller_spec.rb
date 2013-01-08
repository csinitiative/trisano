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

describe ApplicationController do

  it "should return the correct localized path for an error" do
    I18n.locale = :en
    controller.send(:static_error_page_path, 403).should == "#{RAILS_ROOT}/public/403.en.html"
    controller.send(:static_error_page_path, 404).should == "#{RAILS_ROOT}/public/404.en.html"
    controller.send(:static_error_page_path, 422).should == "#{RAILS_ROOT}/public/422.en.html"
    controller.send(:static_error_page_path, 500).should == "#{RAILS_ROOT}/public/500.en.html"
    controller.send(:static_error_page_path, 503).should == "#{RAILS_ROOT}/public/503.en.html"

    I18n.locale = :test
    controller.send(:static_error_page_path, 403).should == "#{RAILS_ROOT}/public/403.test.html"
    controller.send(:static_error_page_path, 404).should == "#{RAILS_ROOT}/public/404.test.html"
    controller.send(:static_error_page_path, 422).should == "#{RAILS_ROOT}/public/422.test.html"
    controller.send(:static_error_page_path, 500).should == "#{RAILS_ROOT}/public/500.test.html"
    controller.send(:static_error_page_path, 503).should == "#{RAILS_ROOT}/public/503.test.html"
  end

  it "should return the default file path for an error if the locale doesn't have a translated error page" do
    I18n.locale = :my_two_year_olds_speak
    controller.send(:static_error_page_path, 403).should == "#{RAILS_ROOT}/public/403.html"
    controller.send(:static_error_page_path, 404).should == "#{RAILS_ROOT}/public/404.html"
    controller.send(:static_error_page_path, 422).should == "#{RAILS_ROOT}/public/422.html"
    controller.send(:static_error_page_path, 500).should == "#{RAILS_ROOT}/public/500.html"
    controller.send(:static_error_page_path, 503).should == "#{RAILS_ROOT}/public/503.html"
  end

  it "should return the default 500 file path for an error that has no error files at all" do
    I18n.locale = :en
    controller.send(:static_error_page_path, 123).should == "#{RAILS_ROOT}/public/500.html"
    controller.send(:static_error_page_path, 342).should == "#{RAILS_ROOT}/public/500.html"
    controller.send(:static_error_page_path, 234).should == "#{RAILS_ROOT}/public/500.html"
  end


end
